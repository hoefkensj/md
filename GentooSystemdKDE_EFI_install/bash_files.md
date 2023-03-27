- # [ QDictator ]

  - class: QModule
  - submodules:
    - TreeBlk

  

- ## [ TreeBlk ]

  - class: QModule

[ TreeBlk.DictSelect ]
	QComboBox
	pol: E.P
	
[ TreeBlk.Tree ]
	cols: 7
	hidecols: 2,3,4,5,6
	pol: E.E
	
[ TreeBlk.TrCtrl ]
	class: QModule
	layout : H


[ TrCtrl.+- ]
	class: QHIncDec
	AutoRaise: 1
	sz_max: 30, 25
	pol: P.P

[ TrCtrl.TreeSearch ]
	class: QHSearch



