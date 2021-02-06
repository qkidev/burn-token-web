<template>
  <div :class="['container', config.chainId === '20181205' ? '' : 'theme-heco']">
    <div class="head">
      <div class="my flex">
        <img :src="require('../../assets/'+assetUrl+'head.png') " class="huo" mode />
        <div class="right">
          <div class="align-center">
            <div class="text">我的算力</div>
            <img :src="require('../../assets/lv' + level + '.png')" class="lv" mode />
          </div>
          <div class="num alignLeft">{{ power }}</div>
          <div class="smallMainInserveTxt alignLeft">累计邀请收益 {{ rewardCount }}</div>
        </div>
      </div>
      <div class="money space-between">
        <div class="item">
          <div class="align-center">
            <img :src="require('../../assets/'+assetUrl+'wdye.png')" class="img" mode />
            <div class="text">我的余额</div>
          </div>
          <div class="num">{{ balance }}</div>
        </div>
        <div class="item">
          <div class="align-center">
            <img :src="require('../../assets/'+assetUrl+'qwtx.png')" class="img1" mode />
            <div class="text">全网通证</div>
          </div>
          <div class="num">{{ totalSupply }}</div>
        </div>
      </div>
      <div class="hy">
        <div class="text alignLeft">燃烧挖矿合约</div>
        <div class="space-between">
          <div class="num ellipsis">{{ contractAddress }}</div>
          <img src="../../assets/copy.png" class="copy" @click="h5Copy(contractAddress)" mode />
        </div>
      </div>
    </div>
    <div class="cont">
      <div class="tab space-between">
        <div class="item" @click="showBurnFlag = true">
          <img :src="require('../../assets/'+assetUrl+'tab1.png')" class="img" mode />
          <div class="text">燃烧原料</div>
        </div>
        <div class="item" @click="showIncome">
          <img :src="require('../../assets/'+assetUrl+'tab2.png')" class="img" mode />
          <div class="text">挖取矿产</div>
        </div>
        <div class="item" @click="lvShow = true">
          <img :src="require('../../assets/'+assetUrl+'level.png')" class="img" mode />
          <div class="text">等级说明</div>
        </div>
        <div class="item" @click="h5Copy(myAddress)">
          <img :src="require('../../assets/'+assetUrl+'tab4.png')" class="img" mode />
          <div class="text">邀请好友</div>
        </div>
      </div>
      <div class="line" v-if="receiveTimestamp != 0">上次领取奖励：{{ receiveTime }}</div>
      <div class="my-box">
        <div class="top space-between">
          <div class="align-center">
            <img :src="require('../../assets/'+assetUrl+'add.png')" class="img" mode />
            <div class="text">我的地址</div>
          </div>
          <div class="text">共邀请 {{ inviteCount }} 人</div>
        </div>
        <div class="copy space-between">
          <div class="num ellipsis">{{ myAddress }}</div>
          <img :src="require('../../assets/'+assetUrl+'copy1.png')" class="copy-img" @click="h5Copy(myAddress)" mode />
        </div>
      </div>
      <div class="my-box">
        <div class="top space-between">
          <div class="align-center">
            <img src="../../assets/bind.png" class="img1" mode />
            <div class="text">绑定邀请人</div>
          </div>
        </div>
        <div class="copy copy1 space-between">
          <div class="num ellipsis" v-if="inviteAddress != ''">{{ inviteAddress }}</div>
          <input
            type="text"
            v-model="inviteAddressInput"
            v-else
            placeholder="请输入邀请人地址"
            class="input_grey num flex1"
          />
          <div
            class="text1"
            v-if="
              inviteAddress != '' &&
              inviteAddress != '0x0000000000000000000000000000000000000000'
            "
          >已绑定</div>
          <div class="flex-box" v-else @click="registration">确定绑定</div>
        </div>
      </div>

      <div class="my-box qkswap">
        <div class="text2"> <img src="../../assets/qks.png" alt="">{{config.tipsDesc}}<a :href="config.tipsUrl" class="link"><b>{{config.tipsUrl}}</b></a></div>
      </div>

      <div class="my-box">
        <div class="text2"><b>Burn Token</b> 的智能合约已通过<b>知道创宇审核</b></div>
        <div class="text"><a class="link" href="https://qkfilecdn.io/ipfs/QmXbSeRoC5QoJgNCvyz4igZZyy1shYgcTmBqSnJCRUafSt">点击查看审核安全报告</a></div>
        <div class="text"><a class="link" href="https://qkfilecdn.io/ipfs/QmeZgnaFybXxFp9SorHTNkoMFZ5zHSmb7BTSSss5Cftmab">Click to view the audit security report</a></div>
      </div>

      <div class="zdcy">
        <div class="item"><img width="30px" src="../../assets/zdcy.png" mode /></div>
        <div class="item">
            <div>知道创宇云安全认证</div>
            <div>WWW.YUNAQ.COM</div>
        </div>
      </div>
    </div>
    <div class="bg" v-show="lvShow">
      <div class="flex-box">
        <div class="box">
          <div class="align-center">
            <img :src="require('../../assets/'+assetUrl+'wenhao.png')" class="wenhao" mode />
            <div class="text">等级说明</div>
          </div>
          <div class="text1 alignLeft">
            <span class="tit">转账手续费销毁功能</span>
            <br />
            <span class="lv first">v1</span>
            <span class="tit">20%</span>
            <span class="lv">v2</span>
            <span class="tit">10%</span>
            <span class="lv">v3</span>
            <span class="tit">8%</span>
            <span class="lv">v4</span>
            <span class="tit">6%</span>
            <span class="lv">v5</span>
            <span class="tit">4%</span>
            <br />
            <br />v1:算力0-499 v2:算力500-4999 v3:算力5000-9999
            v4:算力10000-19999 v5:算力20000+
            <br />*例如转账100个，转出方扣除120个，接收方获得100个，20个销毁。
          </div>
          <div class="flex-box btn" @click="lvShow = false">好的</div>
        </div>
      </div>
    </div>
    <!-- 燃烧原料 -->
    <div class="bg" v-show="showBurnFlag">
      <div class="flex-box">
        <div class="box1">
          <div class="align-center">
            <img :src="require('../../assets/'+assetUrl+'rs.png')" class="rs" mode />
            <div class="text">燃烧原料</div>
          </div>
          <div class="text1 alignLeft">
            可用余额
            <span>{{ balance }}</span>burn
          </div>
          <div class="input-box space-between">
            <input type="text" class="input" value placeholder="输入燃烧数量" v-model="amount" />
            <div class="align-center">
              <div class="text2">burn</div>
              <div class="line"></div>
              <div class="text3" @click="inputAll">全部</div>
            </div>
          </div>
          <div class="tit alignLeft">* 确定提交后你燃烧的余额将销毁变成3倍算力</div>
          <div class="flex-box btn" @click="burn">确定燃烧</div>
          <div class="text4" @click="showBurnFlag = false">取消</div>
        </div>
      </div>
    </div>
    <!-- 挖取矿产 -->
    <div class="bg" v-show="bgShow">
      <div class="flex-box">
        <div class="box1">
          <div class="align-center">
            <img :src="require('../../assets/'+assetUrl+'wq.png')" class="wq" mode />
            <div class="text">挖取矿产</div>
          </div>
          <div class="text5">
            <span>152152.311</span>
            <br />待更新通证算力
          </div>
          <div class="tit tit1">我当前通证算力总量：{{ power }}</div>
          <div class="flex-box btn">增加更新</div>
          <div class="text4" @click="bgShow = false">取消</div>
        </div>
      </div>
    </div>
    <!-- 领取收益弹框 -->
    <div class="bg" v-show="incomeFlag">
      <div class="flex-box">
        <div class="box1">
          <div class="align-center">
            <img :src="require('../../assets/'+assetUrl+'lqjl.png')" class="lq" mode />
            <div class="text">领取收益</div>
          </div>
          <div class="text5" v-if="receiveAble">
            <span class="hugeMainTxt">{{ expectAmount }}</span>
            <br />burn
          </div>
          <div class="time-box" v-else>
            <div class="time" v-for="(item, index) in hour" :key="'1_' + index">{{ item }}</div>

            <div class="bi">:</div>
            <div class="time" v-for="(item, index) in minutes" :key="'2_' + index">{{ item }}</div>
            <div class="bi">:</div>
            <div class="time" v-for="(item, index) in seconds" :key="'3_' + index">{{ item }}</div>
          </div>
          <div class="last-time" v-if="!receiveAble">上次领取奖励：{{ receiveTime }}</div>
          <!-- <div class="tit tit1">* 产出收益最多保留5天</div> -->
          <div class="tit tit1 tit2">* 等级达到Lv2,产出收益最多累计5天</div>
          <div
            :class="['flex-box', receiveAble ? 'btn' : 'btn-disable']"
            @click="getReceiveIncome"
          >{{ receiveAble ? "确定领取" : "明日再来" }}</div>
          <div class="text4" @click="incomeFlag = false">取消</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
// import h5Copy from '../js_sdk/junyi-h5-copy/junyi-h5-copy/junyi-h5-copy.js'
import { h5Copy, initEth, timeUtils, vertify } from "@/utils/utils";
import { ethers } from "ethers";
import { abi, abiPro } from "./abi";
import { Toast } from "vant";
import {GLOBAL_CONFIGS} from '../../utils/global'
// 收益率,为了防止机器刷，LV1级qki余额大于1时，才能够拿到0.2%，否则拿到0.1%
const RATE = ["0.002", "0.005", "0.006", "0.007", "0.008"];
export default {
  data() {
    return {
      contractAddress: "0xD3e9448D573963344f8cF6E95E6b072dc5b701C3", // 合约地址
      contract: null, // 当前的合约对象
      myAddress: "", // 我的地址
      balance: "0.00", // 我的余额
      // totalPower: "0",// 全网通证总量
      totalSupply: "0", // 全网通证总量
      power: "0", // 我的算力
      level: 1,
      lvShow: false,
      bgShow: false,
      type: 1,
      epoch: 86400, // 挖矿周期
      inviteCount: "0", // 邀请的人数
      receiveTimestamp: 0, // 上次领取奖励的时间戳
      receiveTime: "", // 上次领取奖励的时间
      inviteAddress: "", // 已绑定邀请人地址
      inviteAddressInput: "", // 输入邀请人的地址
      rewardCount: 0, // 获取累计收益
      incomeFlag: false, // 领取收益弹框
      deadline: "", // 截止日期
      hour: "00", // 时
      minutes: "00", // 分
      seconds: "00", // 秒
      showBurnFlag: false, // 燃烧算力弹框
      receiveAble: false, // 收益是否可以被领取
      amount: "", // 燃烧数量
      expectAmount: 0, // 预估收益
      decimals: 2, //精度
      config: GLOBAL_CONFIGS,
      assetUrl: process.env.VUE_APP_PLATFORM == 'QKI' ? '' : 'heco/'
    };
  },
  async created() {
    this.contractAddress =
      process.env.NODE_ENV == "development"
        ? "0xD3e9448D573963344f8cF6E95E6b072dc5b701C3"
        : GLOBAL_CONFIGS.contractAdress;
    await this.getAddress();
    let currAbi = process.env.NODE_ENV == "development" ? abi : abiPro;
    var contract = new ethers.Contract(
      this.contractAddress,
      currAbi,
      this.signer
    );
    this.contract = contract;
    await this.getDecimals();
    await this.getEpoch();
    await this.getTotalSupply();
    await this.getinviteCount();
    await this.getReceiveTime();
    await this.getRewardCount();
    await this.getInviteAddress();
    await this.getBalance();
    await this.getPower();
  },
  mixins: [h5Copy, initEth, timeUtils, vertify],
  methods: {
    show(num) {
      this.type = num;
      this.bgShow = true;
    },
    // 展示领取收益
    async showIncome() {
      // 新用户且算力不为0，进入页面就可以领取一次收益
      if (this.receiveTimestamp == 0) {
        if (this.power != 0) {
          this.receiveAble = true;
          this.incomeFlag = true;
          // 默认领取一天的收益，传入参数只要是小于epoch的任何一个数都可以
          this.calcExpectAmount(10);
        } else {
          Toast("您当前还没有算力！");
          return;
        }
      } else {
        this.incomeFlag = true;
        let nowTimeStr = Date.now()
          .toString()
          .substring(0, 10);
        let distance = this.receiveTimestamp + this.epoch - Number(nowTimeStr);
        // 如果distance大于0表示收益还不可以领取。需要计算倒计时
        if (distance <= 0) {
          this.calcExpectAmount(distance);
        }
      }
    },
    async getAddress() {
      let [error, address] = await this.to(this.signer.getAddress());
      if (error == null) {
        this.myAddress = address;
      } else {
        console.log(error);
      }
    },
    // 获取主网qki的余额
    async getQkiBalance() {
      let [error, balance] = await this.to(
        this.provider.getBalance(this.myAddress)
      );
      if (error == null) {
        let etherString = ethers.utils.formatEther(balance);
        return parseFloat(etherString);
      }
      return 0.0;
    },
    // 得到余额
    async getBalance() {
      let [error, balance] = await this.to(
        this.contract.balanceOf(this.myAddress)
      );
      this.doResponse(error, balance, "balance", this.decimals);
    },
    // 得到通证总量
    async getTotalSupply() {
      let [error, res] = await this.to(this.contract.totalSupply());
      this.doResponse(error, res, "totalSupply", this.decimals);
    },
    // 得到精度
    async getDecimals() {
      let [error, res] = await this.to(this.contract.decimals());
      this.doResponse(error, res, "decimals");
    },
    // 得到个人算力
    async getPower() {
      let [error, res] = await this.to(this.contract.power(this.myAddress));
      this.doResponse(error, res, "power", this.decimals);
    },
    // 获取累计收益
    async getRewardCount() {
      let [error, res] = await this.to(
        this.contract.rewardCount(this.myAddress)
      );
      this.doResponse(error, res, "rewardCount", this.decimals);
    },
    // 获取上次领取奖励的时间
    // 注：这个方法必须调用在getEpoch方法之后，因为他们两个共同影响倒计时的逻辑
    async getReceiveTime() {
      let [error, res] = await this.to(
        this.contract.last_miner(this.myAddress)
      );
      this.doResponse(error, res, "receiveTimestamp");
    },
    // 获取挖矿周期
    async getEpoch() {
      let [error, res] = await this.to(this.contract.epoch());
      this.doResponse(error, res, "epoch");
    },
    // 获取邀请人数
    async getinviteCount() {
      let [error, res] = await this.to(
        this.contract.inviteCount(this.myAddress)
      );
      this.doResponse(error, res, "inviteCount");
    },
    // 获取绑定人信息
    async getInviteAddress() {
      let [error, res] = await this.to(this.contract.invite(this.myAddress));
      if (this.doResponse(error, res)) {
        if (res == "0x0000000000000000000000000000000000000000") {
          res = "";
        }
        this.inviteAddress = res;
      }
    },
    // 绑定邀请人。
    async registration() {
      if (this.inviteAddressInput == "") {
        Toast("请输入绑定邀请的地址");
        return;
      }
      if(this.inviteAddressInput.toLowerCase() == this.myAddress.toLowerCase()){
         Toast("不能绑定自己！");
          this.inviteAddressInput = '';
        return;
      }
      if (this.inviteAddressInput.toLowerCase() == this.contractAddress.toLowerCase()) {
        Toast("不能绑定合约地址为邀请人！");
        this.inviteAddressInput = '';
        return;
      }

      // TODO: 如何验证地址的合法性？？
      let [error, res] = await this.to(
        this.contract.registration(this.inviteAddressInput)
      );
      if (this.doResponse(error, res)) {
        Toast("绑定成功");
        this.inviteAddress = this.inviteAddressInput;
      }
    },
    // 燃烧
    async burn() {
      if (this.amount == "") {
        Toast("请输入您的燃烧数量");
        return;
      }
      let burn_amount =
        ethers.FixedNumber.from(this.amount.toString()) * 10 ** this.decimals;
      let [error, res] = await this.to(this.contract.burn(burn_amount));
      if (this.doResponse(error, res)) {
        this.showBurnFlag = false;
        Toast("操作成功");
        await this.queryTransation(res.hash);
      }
    },
    // 领取挖矿收益
    async getReceiveIncome() {
      if (!this.receiveAble) {
        Toast("您今天已经领取过收益了,明天再来！");
        return;
      }
      let [error, res] = await this.to(this.contract.mint());
      if (this.doResponse(error, res, "")) {
        this.incomeFlag = false;
        Toast("收益领取成功！");
        await this.queryTransation(res.hash, true);
      }
    },
    // 查询Transaction
    async queryTransation(hash, updateTime) {
      await this.provider.waitForTransaction(hash).then(async receipt => {
        Toast("区块打包成功", receipt);
        await this.getBalance();
        await this.getPower();
        await this.getTotalSupply();
        if (updateTime) {
          await this.getRewardCount();
          await this.getEpoch();
          await this.getReceiveTime();
        }
      });
    },
    async calcExpectAmount(distance) {
      // 计算阶段奖励
      let currRate = "0.001";
      if (this.level == 1) {
        let balance = await this.getQkiBalance();
        if (balance < 1) {
          currRate = "0.001";
        } else {
          currRate = RATE[this.level - 1];
        }
      } else {
        currRate = RATE[this.level - 1];
      }
      // 奖励是否过期
      let day = Math.floor(Math.abs(distance) / this.epoch);
      day = day + 1;
      // let expectAmount = this.accMul(this.power, currRate);
      if (this.timestampToTime == 0) {
        day = 1;
      } else {
        if (this.level == 1) {
          if (day > 1) {
            day = 1;
          }
        } else {
          if (day > 5) {
            day = 5;
          }
        }
      }

      // let par1 =
      this.expectAmount = this.accMul(this.accMul(this.power, currRate), day);
    },
    // 十六进制转10进制
    hex2int(hex) {
      if (hex.indexOf("0x") >= 0) {
        hex = hex.substring("2");
      }
      var len = hex.length,
        a = new Array(len),
        code;
      for (var i = 0; i < len; i++) {
        code = hex.charCodeAt(i);
        if (48 <= code && code < 58) {
          code -= 48;
        } else {
          code = (code & 0xdf) - 65 + 10;
        }
        a[i] = code;
      }
      return a.reduce(function(acc, c) {
        acc = 16 * acc + c;
        return acc;
      }, 0);
    },
    // response公共处理方法
    doResponse(error, res, keyName, Decimal = 0) {
      // console.log(keyName+'================', error, res);
      if (error == null) {
        if (keyName) {
          let hex = ethers.utils.hexValue(res);
          let Value =
            this.hex2int(hex) / ethers.BigNumber.from(10).pow(Decimal);
          this[keyName] = Value;
        }
        return true;
      } else {
        if (error.code == "INSUFFICIENT_FUNDS") {
          Toast("矿工费不足");
        } else if (error.code == 4001) {
          Toast("用户取消");
        } else {
          Toast("错误代码:" + error.code);
        }
        return false;
      }
    },
    // 输入全部
    inputAll() {
      this.amount = this.balance;
    },

    tab(num) {
      this.active = num;
    }
  },
  // computed: {
  //   receiveAble: function(){
  //     // 获取当前时间
  //     let nowTimeStr = Date.now()
  //       .toString()
  //       .substring(0, 10);
  //     return Number(nowTimeStr) - (this.receiveTimestamp + this.epoch) > 0
  //   }
  // },
  watch: {
    power(newPower) {
      if (newPower < 500) {
        this.level = 1;
      } else if (newPower < 5000) {
        this.level = 2;
      } else if (newPower < 10000) {
        this.level = 3;
      } else if (newPower < 20000) {
        this.level = 4;
      } else {
        this.level = 5;
      }
    },
    receiveTimestamp(newTime) {
      if (newTime != 0) {
        this.receiveTime = this.timestampToTime(this.receiveTimestamp);
      }
      // 获取当前时间
      let nowTimeStr = Date.now()
        .toString()
        .substring(0, 10);
      // 如果distance大于0表示收益还不可以领取。需要计算倒计时
      let distance = this.receiveTimestamp + this.epoch - Number(nowTimeStr);
      if (distance > 0) {
        this.countDown(distance, () => {
          this.calcExpectAmount(distance);
          this.receiveAble = true;
        });
        this.receiveAble = false;
      } else {
        this.calcExpectAmount(distance);
        this.receiveAble = true;
      }
    }
  }
};
</script>

<style scoped lang="scss">
.flex {
  display: flex;
}
.flex-box {
  display: flex;
  align-items: center;
  justify-content: center;
}
.align-center {
  display: flex;
  align-items: center;
}
.space-between {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.text-overflow {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.head {
  width: 100%;
  height: 500px;
  background: url(../../assets/bj.png) no-repeat;
  background-size: 100% 100%;
  padding-top: 100px;
  position: relative;
  box-sizing: border-box;
  .my {
    margin-left: 101px;

    .huo {
      width: 93px;
      height: 104px;
    }

    .right {
      margin-left: 29px;
      margin-top: -10px;

      .num {
        font-size: 58px;
        color: #fff;
        font-weight: bold;
      }

      .align-center {
        .lv {
          width: 44px;
          height: 28px;
          margin-left: 10px;
        }

        .text {
          font-size: 26px;
          color: #ffcdcd;
          margin-left: 11px;
        }
      }
    }
  }

  .money {
    margin-top: 70px;
    padding: 0 110px;

    .item {
      text-align: center;

      .img {
        width: 33px;
        height: 31px;
      }

      .img1 {
        width: 25px;
        height: 33px;
      }

      .text {
        font-size: 24px;
        color: #ffcdcd;
        margin-left: 10px;
      }

      .num {
        font-size: 26px;
        color: #fff;
        font-weight: bold;
        margin-top: 10px;
      }
    }
  }

  .hy {
    // margin-left: 50px;
    // margin-right: 50px;
    // width: 653px;
    height: 112px;
    background: linear-gradient(135deg, #ffc308 0%, #f6874f 100%);
    border-radius: 30px;
    margin: 40px 50px 0 50px;
    padding: 23px 45px 0 50px;
    position: relative;
    z-index: 9;
    box-sizing: border-box;
    .text {
      font-size: 24px;
      color: #fff;
      font-weight: bold;
    }

    .space-between {
      margin-top: 4px;

      .num {
        font-size: 20px;
        color: #fff;
        font-weight: bold;
      }

      .copy {
        width: 34px;
        height: 34px;
      }
    }
  }
}

.cont {
  width: 100%;
  background: #ffffff;
  box-shadow: 0px -27px 81px 0px rgba(0, 0, 0, 0.02);
  border-radius: 35px 35px 0px 0px;
  margin-top: -28px;
  position: relative;
  padding-top: 103px;
  padding-bottom: 100px;
  .tab {
    padding: 0 58px;

    .item {
      text-align: center;

      .img {
        width: 116px;
        height: 116px;
      }

      .text {
        font-size: 26px;
        color: #737278;
        margin-top: 16px;
      }
    }
  }

  .line {
    text-align: center;
    font-size: 22px;
    color: #c0c0c0;
    // width: 608px;
    height: 2px;
    margin: 53px auto 0 auto;
    padding-top: 20px;
    border-top: 1px solid #f2f2f2;
  }

  .my-box {
    margin-top: 60px;
    padding: 0 48px;

    .img {
      width: 26px;
      height: 35px;
    }

    .img1 {
      width: 30px;
      height: 30px;
    }

    .text, .text2 {
      font-size: 24px;
      color: #b09b99;
      margin-left: 14px;
    }

    .text1 {
      font-size: 24px;
      color: #7d7d82;
    }

    .copy {
      width: 100%;
      height: 65px;
      background: #fff1ef;
      border-radius: 21px;
      padding: 0 45px 0 42px;
      margin-top: 26px;
      box-sizing: border-box;
      &.copy1 {
        height: 102px;
        background: #f3f3f3;
        padding: 0 33px 0 40px;
      }

      .flex-box {
        width: 156px;
        height: 62px;
        background: #dc5242;
        border-radius: 16px;
        font-size: 24px;
        color: #fff;
      }

      .num {
        font-size: 20px;
        color: #737278;
      }

      .copy-img {
        width: 34px;
        height: 34px;
      }
    }
  }
}

.bg {
  width: 100%;
  height: 100%;
  position: fixed;
  top: 0;
  left: 0;
  z-index: 99;
  background: rgba($color: #000000, $alpha: 0.5);

  .flex-box {
    width: 100%;
    height: 100%;

    .box {
      width: 654px;
      height: 673px;
      background: #ffffff;
      border-radius: 20px;
      padding: 90px 78px 0 63px;
      box-sizing: border-box;
      .wenhao {
        width: 40px;
        height: 40px;
      }

      .text {
        font-size: 38px;
        color: #7d7d82;
        margin-left: 10px;
        font-weight: bold;
      }

      .text1 {
        font-size: 26px;
        color: #7d7d82;
        margin-top: 30px;
        line-height: 37px;

        .tit {
          font-weight: 600;
        }

        .lv {
          color: #dc5242;
          padding-right: 10px;
          padding-left: 10px;

          &.first {
            padding-left: 0;
          }
        }
      }

      .btn {
        width: 100%;
        height: 120px;
        background: #dc5242;
        border-radius: 20px;
        font-size: 32px;
        color: #fff;
        margin-top: 50px;
      }
    }

    .box1 {
      margin-left: 50px;
      margin-right: 50px;

      width: 100%;
      // height: 699px;
      background: #ffffff;
      border-radius: 20px;
      padding: 71px 56px 71px 56px;
      .rs {
        width: 30px;
        height: 45px;
      }
      .lq {
        width: 42px;
        height: 38px;
      }
      .wq {
        width: 40px;
        height: 40px;
      }
      .text {
        font-size: 38px;
        color: #7d7d82;
        font-weight: bold;
        margin-left: 13px;
      }
      .text1 {
        font-size: 26px;
        color: #b9b9b9;
        font-weight: 500;
        margin-top: 13px;
        uni-text {
          color: #dc5242;
        }
      }

      .text2 {
        font-size: 26px;
        color: #b9b9b9;
        font-weight: bold;
      }
      .line {
        width: 1px;
        height: 51px;
        background: #d8d8d8;
        margin: 0 13px;
      }
      .text3 {
        font-size: 26px;
        font-weight: 500;
        color: #dc5242;
      }
      .tit {
        font-size: 24px;
        color: #dc5242;
        font-weight: 500;
        margin-top: 73px;
        &.tit1 {
          text-align: center;
        }
        &.tit2 {
          margin-top: 26px;
        }
      }
      .btn {
        width: 100%;
        height: 120px;
        background: #dc5242;
        border-radius: 20px;
        font-size: 32px;
        color: #fff;
        margin-top: 28px;
      }
      .btn-disable {
        width: 100%;
        height: 120px;
        background: #ccc;
        border-radius: 20px;
        font-size: 32px;
        color: #fff;
        margin-top: 50px;
      }
      .text4 {
        text-align: center;
        font-size: 32px;
        color: #b9b9b9;
        margin-top: 34px;
      }
      .text5 {
        text-align: center;
        font-size: 24px;
        color: #b9b9b9;
        margin-top: 80px;
        span {
          font-size: 50px;
          color: #dc5242;
          font-weight: 500;
        }
      }
      .time-box {
        margin-top: 50px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        .time {
          display: flex;
          justify-content: center;
          align-items: center;
          width: 77px;
          height: 100px;
          background: #f3f3f3;
          border-radius: 19px;
          font-size: 50px;
          color: #7d7d82;
          font-weight: bold;
        }
        .bi {
          font-size: 35px;
          color: #7d7d82;
        }
      }
      .last-time {
        text-align: center;
        margin-top: 60px;
        font-size: 22px;
        color: #c0c0c0;
      }
    }
  }
}
.input-box {
  width: 100%;
  height: 120px;
  background: #f3f3f3;
  border-radius: 20px;
  margin-top: 34px;
  padding: 0 37px;
  box-sizing: border-box;
  .input {
    width: 70%;
    height: 100%;
    border: none;
    background-color: transparent;
  }
}

.link {
    color: #b09b99;
    text-decoration-line: underline;
}

.qkswap {
  img {
    width: 35px;
    vertical-align: middle;
  }

  .text {
    border-bottom: 2px solid #F2F2F2;
    padding-bottom: 35px;
  }
}

.zdcy {
  margin-top: 42px;
  display: flex;
  justify-content:center;
  align-items: center;
  color: #b09b99;
  font-size: 11px;
  font-weight: bold;
  .item {
    text-align: left;
  }

  img {
    display: block;
    margin-right: 15px;
  }
}
.theme-heco{
  .head {
    background: url(../../assets/heco/bj.png) no-repeat;
    .my {
      .right {
        .align-center {
          .text {
            color: #fff;
          }
        }
      }
    }
    .money {
      .item {
        .text {
          color: #fff;
        }
      }
    }
  }
  .cont{
    .my-box {
      .text {
        color:#001D52;
      }
      .text1 {
        font-size: 24px;
        color: #7d7d82;
      }
      .text2 {
        color: #b09b99;
      }
      .copy {
        background: #DFE7FF;
        &.copy1 {
          height: 102px;
          background: #f3f3f3;
          padding: 0 33px 0 40px;
        }

        .flex-box {
          background: #536689;
        }

        .num {
          color: #001D52;
        }
      }
    }
  }
  .bg {
    .flex-box {
      .box {
        .text1 {
          .lv {
            color: #1C6DF1;
          }
        }
        .btn {
          background: #1C6DF1;
        }
      }
      .box1 {
        .text1 {
          span {
            color:#6F81A8;
          }
        }
        .text3 {
          color: #092559;
        }
        .tit {
          color: #001D52;
        }
        .btn {
          background: #1C6DF1;
        }
      }
    }
  }
  .hy {
    background: linear-gradient(135deg, #005AFF 0%, #337CE4 100%);
  }
  
}
</style>
