// SPDX-License-Identifier: SimPL-2.0
pragma solidity  ^0.7.6;

/**
 * Math operations with safety checks
 */
contract SafeMath {
  function safeMul(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
}
interface  burn_token {
    //获取老合约的算力
    function power(address owner) external view returns (uint256);
    function invite(address owner) external view returns (address);
    function last_miner(address owner) external view returns (address);
}

library TransferHelper {
    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
}

contract burn_token_v2 is SafeMath{
    string public name;
    string public symbol;
    uint8 public decimals = 3;
    uint public epoch_base = 86400;//挖矿周期基数，不变
    uint public epoch = 86400;//挖矿周期，随着时间变化
    uint public start_time = 1607305807;//挖矿开始时间
    uint256 public totalSupply;
    uint256 public totalPower;//总算力
    uint256 public totalUsersAmount;//总用户数
    address payable public owner;
    bool public is_airdrop = true;//是否开启空投，开启空投不能挖矿
    bool public is_upgrade = true;//是否开启老合约升级到新合约
    bool public is_mint = true;//是否开启挖矿
    
    uint public anti_bot = 100e6;//如果v1用户usdt余额小于这个值，不能挖矿
    uint public min_gasprice = 1 gwei;//最低gas价格
    address public requireToken = 0xDF0e293CC3c7bA051763FF6b026DA0853D446E38;//usdt


    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    //      user             token        balance
    mapping (address => mapping(address => uint256)) public TokenBalanceOf;
    mapping (address => address) public invite;//邀请
    mapping (address => uint256) public power;//算力
    mapping (address => uint256) public last_miner;//用户上次挖矿时间
    mapping (address => uint256) public freezeOf;
    mapping (address => uint256) public inviteCount;//邀请人好友数
    mapping (address => uint256) public rewardCount;//累计奖励
    mapping (address => mapping (address => uint256)) public allowance;//授权

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* This notifies clients about the amount burnt */
    event Burn(address indexed from, uint256 value);
	
	/* This notifies clients about the amount frozen */
    event Freeze(address indexed from, uint256 value);
	
	/* This notifies clients about the amount unfrozen */
    event Unfreeze(address indexed from, uint256 value);

    // 铸币事件
    event Minted(
        address indexed operator,
        address indexed to,
        uint256 amount
    );

    
    event  Deposit(address indexed dst,address token, uint wad);
    event  Withdrawal(address indexed src,address token, uint wad);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint epoch_time
        ) {
        totalSupply = 0;// Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        owner = msg.sender;
        epoch_base = epoch_time;
        epoch = epoch_base;
    }

    

    receive() payable external {
    }
    
    function withdraw(uint amount) public {
        require(msg.sender == owner);
        owner.transfer(amount);
    }


    function depositToken(address token,uint256 amount) public {
        TransferHelper.safeTransferFrom(token, msg.sender, address(this), amount);
        TokenBalanceOf[msg.sender][token] += amount;
        emit Deposit(msg.sender,token, amount);
    }

    function withdrawToken(address token,uint256 amount) public {
        require(block.timestamp - last_miner[msg.sender] >= 86400);//挖矿24小时后才能提交
        require(TokenBalanceOf[msg.sender][token] >= amount);
        TokenBalanceOf[msg.sender][token] -= amount;
        TransferHelper.safeTransfer(token,msg.sender,amount);
        Withdrawal(msg.sender,token, amount);
    }


    /* Send coins */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0)); // Prevent transfer to 0x0 address. Use burn() instead
		require(_value > 0); 
        require(msg.sender != _to);//自己不能转给自己

        uint fee = transfer_fee(msg.sender,_value);
        uint sub_value = SafeMath.safeAdd(fee, _value); //扣除余额需要计算手续费  
        
        require(balanceOf[msg.sender] >= sub_value);//需要计算加上手续费后是否够
        if (balanceOf[_to] + _value < balanceOf[_to]) revert("overflows"); // Check for overflows

        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], sub_value);// Subtract from the sender
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                            // Add the same to the recipient
        totalSupply -= fee;//总量减少手续费
        emit Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
        if(fee > 0)
        emit Burn(msg.sender, fee);
        return true;
    }

    function transfer_fee(address _from,uint256 _value) public view returns (uint256 fee) {
        uint8 scale = 20;// n/100
        //没有挖矿用户免手续费
        if(last_miner[_from] == 0)
        {
            scale = 0;
            return 0;
        }
        else if(power[_from] < 500 * 1e3)
        {
            scale = 20;
        }
        else if(power[_from] < 5000 * 1e3)
        {
            scale = 10;   
        }
        else if(power[_from] < 10000 * 1e3)
        {
            scale = 8;   
        }
        else if(power[_from] < 20000 * 1e3)
        {
            scale = 6;   
        }
        else if(power[_from] >= 20000 * 1e3)
        {
            scale = 4;   
        }
        uint256 _fee = _value * scale / 100;
        return _fee;
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require(!((_value != 0) && (allowance[msg.sender][_spender] != 0)));

		require(_value >= 0); 
        allowance[msg.sender][_spender] = _value;
        return true;
    }
       

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)  {
        if (_to == address(0)) revert();                                // Prevent transfer to 0x0 address. Use burn() instead
		if (_value <= 0) revert(); 
        require(_from != _to);//自己不能转给自己

        uint fee = transfer_fee(_from,_value);
        uint sub_value = SafeMath.safeAdd(fee, _value);   

        
        if (balanceOf[_from] < sub_value) revert();                 // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) revert();  // Check for overflows
        if (sub_value > allowance[_from][msg.sender]) revert();     // Check allowance

        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], sub_value);                           // Subtract from the sender
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                             // Add the same to the recipient
        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], sub_value);
        totalSupply -= fee;//总量减少手续费
        emit Transfer(_from, _to, _value);
        if(fee > 0)
        emit Burn(_from, fee);
        return true;
    }

    function burn(uint256 _value) public returns (bool success)  {
        if(tx.gasprice < min_gasprice) revert("min_gasprice");
        require(balanceOf[msg.sender] >= _value);            // Check if the sender has enough
		require(_value > 0); 
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      // Subtract from the sender
        totalSupply = SafeMath.safeSub(totalSupply,_value);                                // Updates totalSupply
        if(power[msg.sender] == 0)
            totalUsersAmount++;
        power[msg.sender] += _value * 3;//燃烧加算力
        emit Burn(msg.sender, _value);
        totalPower += _value * 3;//加累计算力
        reward_upline(_value);//给上级奖励
        return true;
    }
    
    function reward_upline(uint256 _value) private returns (bool success){
        //邀请人不能为空
        if(invite[msg.sender] != address(0))
        {
            address invite1 = invite[msg.sender];

            //零算力不奖励
            if(power[invite1] == 0)
                return true;
            uint8 scale = 2;// n/100 通证数量乘以精度单位
            if(power[invite1] < 500 * 1e3)
            {
                scale = 2;
            }
            else if(power[invite1] < 5000 * 1e3)
            {
                scale = 5;   
            }
            else if(power[invite1] < 10000 * 1e3)
            {
                scale = 6;   
            }
            else if(power[invite1] < 20000 * 1e3)
            {
                scale = 7;   
            }
            else if(power[invite1] >= 20000 * 1e3)
            {
                scale = 8;   
            }
            //小数支持不好，就先乘后除的方法
            uint256 reward = _value * scale / 100;
            //如果本次算力大于上级
            if(power[invite1] < reward)
            {
                reward = power[invite1];
            }
        
            power[invite1] = power[invite1] - reward;//减少邀请人算力
            totalPower = totalPower - reward;//减少总算力
            balanceOf[invite1] =  balanceOf[invite1] + reward;//增加邀请人余额
            totalSupply = totalSupply + reward;//增加总量
            rewardCount[invite1] += reward;//记录累计奖励
            emit Minted(msg.sender,invite1,reward);
            
            if(invite[invite1] != address(0))
            {
                address invite2 =  invite[invite1];

                //零算力不奖励
                if(power[invite2] == 0)
                    return true;
                
                scale = 2;// n/100
                if(power[invite2] < 500 * 1e3)
                {
                    scale = 0;
                }
                else if(power[invite2] < 5000* 1e3)
                {
                    scale = 1;   
                }
                else if(power[invite2] < 10000 * 1e3)
                {
                    scale = 2;   
                }
                else if(power[invite2] < 20000 * 1e3)
                {
                    scale = 3;   
                }
                else if(power[invite2] >= 20000 * 1e3)
                {
                    scale = 4;   
                }
                reward = _value * scale / 100;
                //Check
                if(power[invite2] < reward)
                {
                    reward = power[invite2];
                }
            
                power[invite2] = power[invite2] - reward;//减少邀请人算力
                totalPower = totalPower - reward;//减少总算力
                balanceOf[invite2] =  balanceOf[invite2] + reward;//增加邀请人余额
                totalSupply = totalSupply + reward;//增加总量
                rewardCount[invite2] += reward;//记录累计奖励
                emit Minted(msg.sender,invite2,reward);
                return true;
            }
            return true;
        }
        return true;
    }
	
	function freeze(uint256 _value) public returns (bool success)  {
        if (balanceOf[msg.sender] < _value) revert();            // Check if the sender has enough
		if (_value <= 0) revert(); 
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      // Subtract from the sender
        freezeOf[msg.sender] = SafeMath.safeAdd(freezeOf[msg.sender], _value);                                // Updates totalSupply
        Freeze(msg.sender, _value);
        return true;
    }
	
	function unfreeze(uint256 _value) public returns (bool success) {
        if (freezeOf[msg.sender] < _value) revert();            // Check if the sender has enough
		if (_value <= 0) revert(); 
        freezeOf[msg.sender] = SafeMath.safeSub(freezeOf[msg.sender], _value);                      // Subtract from the sender
		balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender], _value);
        Unfreeze(msg.sender, _value);
        return true;
    }

    //老合约升级到新合约
    function upgrade() public{
        if(tx.gasprice < min_gasprice) revert("min_gasprice");
        require(power[msg.sender] == 0);//零算力账号才可以
        require(is_upgrade);//需要开启空投
        uint256 hbt_power = burn_token(0x3FB708e854041673433e708feDb9a1b43905b6f7).power(msg.sender);
        if(hbt_power > 100)//老合约没有算力就不用升级
        {
            power[msg.sender] = hbt_power;
            totalPower += hbt_power;
            totalUsersAmount++;
        }
        uint256 hbt_invite  = burn_token(0x3FB708e854041673433e708feDb9a1b43905b6f7).invite(msg.sender);
        if(hbt_invite != address(0))
        {
            invite[msg.sender] = hbt_invite;//记录邀请人
            inviteCount[hbt_invite] += 1;//邀请人的下级数加一
        }
    }
    

    
    function setOwner(address payable new_owner) public {
        require(msg.sender == owner);
        owner = new_owner;
    }
    
    //暂停升级,升级只有一次机会
    function stop_upgrade() public{
        require(msg.sender == owner);
        require(is_upgrade);
        is_upgrade = false;
    }
    

    //设置一个值，如果用户的token余额小于这个值，而且算力小于500，不能挖矿，限制刷子
    function set_anti_bot(uint _value) public{
        require(msg.sender == owner);
        anti_bot = _value;
    }
    
    //设置质押的token，后面可能会换成husd
    function set_require_token(address token) public{
        require(msg.sender == owner);
        requireToken = token;
    }

    //设置一个值，如果用户调用gasprice小于这个值，就提交失败，限制刷子
    function set_min_gasprice(uint _value) public{
        require(msg.sender == owner);
        min_gasprice = _value;
    }
    
    
    function update_epoch() private returns (bool success){
        epoch =  epoch_base + (block.timestamp - start_time)/365;
        return true;
    }
    
    
    function registration(address invite_address) public returns (bool success){
        require(invite[msg.sender] == address(0));//现在没有邀请人
        require(msg.sender != invite_address);//不能是自己
        invite[msg.sender] = invite_address;//记录邀请人
        inviteCount[invite_address] += 1;//邀请人的下级数加一
        return true;
    }
    
    function mint() public returns (bool success){
        require(is_mint,"not start mint");
        require(power[msg.sender] > 0);//算力不能为零
        require(block.timestamp - last_miner[msg.sender] >= epoch); //距离上次挖矿大于一个周期
        if(tx.gasprice < min_gasprice) revert("min_gasprice");
        update_epoch();//每次都更新基础周期值
        uint8 scale = 20;// 万分之n
        if(power[msg.sender] < 500 * 1e3)
        {
            scale = 20;
            //用户合约内锁仓token余额小于一个值，就不能挖矿
            require(TokenBalanceOf[msg.sender][requireToken] >= anti_bot,"token too low");
        }
        else if(power[msg.sender] < 5000* 1e3)
        {
            scale = 50;   
        }
        else if(power[msg.sender] < 10000 * 1e3)
        {
            scale = 60;   
        }
        else if(power[msg.sender] < 20000 * 1e3)
        {
            scale = 70;   
        }
        else if(power[msg.sender] >= 20000 * 1e3)
        {
            scale = 80;   
        }

        uint miner_days=(block.timestamp - last_miner[msg.sender])/epoch;
        
        if(miner_days > 5)
        {
            miner_days = 5;//单次最多领取7天的
        }
        
        //第一次挖矿只能1天
        if(last_miner[msg.sender] == 0)
        {
            miner_days = 1;
        }

        //v2及以上可以5天 v1只能每天领
        if(miner_days > 1 && power[msg.sender] < 500 * 1e3)
        {
            miner_days = 1;
        }

        //算力*比例*天数
        uint256 reward = power[msg.sender] * miner_days * scale / 10000;
        power[msg.sender] = power[msg.sender] - reward;//算力减去本次转换的
        totalPower = totalPower - reward;//减少总算力
        balanceOf[msg.sender] =  balanceOf[msg.sender] + reward;//增加余额
        totalSupply = totalSupply + reward;//增加总量
        last_miner[msg.sender] = block.timestamp;//记录本次挖矿时间
        emit Minted(msg.sender,msg.sender,reward);
        return true;
    }
}