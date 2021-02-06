const QKI_CONFIG = {
  chainId: '20181205',
  chainIdHex: '0x133f0d5',
  tipsDesc: '推荐使用qkswap交换bt和其它通证，避免被骗。  qkswap可以点击进入',
  tipsUrl: 'https://app.qkswap.io',
  openPluginToast : '请安装metamask插件、或者使用qkpay打开',
  toggleToast : '请使用QKI主网,请切换到QKI主网',
  useToast: '请使用qki主网',
  toggleToast2: '你当前没有使用QKI主网，请切换主网为QKI',
  contractAdress: '0x3FB708e854041673433e708feDb9a1b43905b6f7'
}
const HT_CONFIG = {
  chainId: '20181206',
  chainIdHex: '0x133f0d5',
  tipsDesc: '推荐使用qkswap交换bt和其它通证，避免被骗。  qkswap可以点击进入2333',
  tipsUrl: 'https://heco.burnbt.io ',
  openPluginToast : '请安装metamask插件、或者使用qkpay打开2333',
  toggleToast : '请使用QKI主网,请切换到QKI主网2333',
  useToast: '请使用qki主网2333',
  toggleToast2: '你当前没有使用QKI主网，请切换主网为QKI2333',
  contractAdress: '0x3FB708e854041673433e708feDb9a1b43905b6f7'
}
const GLOBAL_CONFIGS = process.env.VUE_APP_PLATFORM == 'QKI' ? QKI_CONFIG : HT_CONFIG
export {
  GLOBAL_CONFIGS
};
