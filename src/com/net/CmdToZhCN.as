package com.net
{
	/**
	 * cmd2name
	 */
	public class CmdToZhCN
	{
		private static var _my:CmdToZhCN;
		
		public static var id2name:Object = {
				'b002':'处理常务',
				'b006':'武将修习',
				'b007':'武将培养',
				'b008':'武将钻研',
				'b009':'巡查',
				'b00b':'开仓',
				'b00c':'耕作',
				'b00d':'征收粮食',
				'b00e':'强征粮食',
				'b00f':'拓展',
				'b010':'征收银两',
				'b011':'强征银两',
				'b012':'提升技术值',
				'b013':'武器改良',
				'b014':'防具改良',
				'b016':'征兵',
				'b017':'强行征兵',
				'b018':'修筑城墙',
				'b019':'抢修城墙',
				'b01a':'城池升级',
				'b01e':'修习突飞猛进',
				'b01f':'减少突飞猛进CD',
				'b020':'取消修习',
				'b022':'取消钻研',
				'b023':'减少CD时间',
				'b025':'购买行动力',
				'b027':'武将技能解锁',
				'b028':'武将技能遗忘',
				'b200':'发布个人攻打任务',
				'b201':'发布个人收集任务',
				'b202':'发布个人收集任务',
				'b207':'完成个人任务',
				'b208':'取消个人任务',
				'6103':'休妻',
				'6104':'让儿子加入帐下',
				'6110':'刷妻妾',
				'6111':'招妻妾',
				'c000':'地区赋税调整',
				'c001':'太守寻访',
				'c004':'个人科技研究',
				'ce04':'名称科技研究',
				'cf04':'国家科技研究',
				'c007':'出售粮食',
				'c008':'购买粮食',
				'ff01':'使用道具',
				'c00a':'出售商品',
				'c00b':'购买商品',
				'c00c':'装备升级',
				'c00e':'刷将',
				'c00f':'招募武将',
				'c010':'刷马',
				'c011':'马匹驯养',
				'c013':'打探消息',
				'c014':'物品兑换',
				'c016':'神秘道具购买',
				'c018':'解雇武将',
				'c019':'国家赋税调整',
				'c024':'自动刷将',
				'c031':'国家征税',
				'cc00':'君王巡视',
				'cd01':'修改公告',
				'cd02':'投票',
				'cd06':'提取府库银两',
				'cd08':'提取国库银两',
				'd000':'配置出征队列',
				'd001':'PVE',
				'd002':'创建战役',
				'd007':'PVP',
				'd020':'加入竞技场',
				'd023':'竞技场挑战',
				'd040':'加入皇帝/太守争夺战',
				'd052':'副本战斗',
				'd054':'武将副本战斗',
				'd055':'任务武将战斗',
				'd057':'重置武将副本',
				'e001':'完成任务'
			};
		
		public function CmdToZhCN()
		{
			if(_my) throw new Error('CmdToZhCN must be only one!');
		}
		
		public static function get my():CmdToZhCN
		{
			return _my;
		}
		
		public function toString(cmd:String):String
		{
			cmd = id2name[cmd];
			return cmd;
		}
	}
}