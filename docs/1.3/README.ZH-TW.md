# GMUI - Godot MVVM UI  
Godot遊戲引擎的 MVVM UI框架   

> [English](https://github.com/JustDooooIt/GMUI)&nbsp;&nbsp;&nbsp;[簡體中文](https://github.com/JustDooooIt/GMUI/blob/master/README.ZH.md)&nbsp;&nbsp;&nbsp;[繁體中文](https://github.com/JustDooooIt/GMUI/blob/master/README.ZH-TW.md)   
> GMUI版本：1.3.x   &nbsp;&nbsp;&nbsp;&nbsp;Godot版本：4.x  

> 最新情報  
> 1.3版本更新內容:    
>> 1. 新增監聽屬性   
>> 2. 新增計算屬性   
>> 3. 新增條件編譯   
>> 4. 修復了已知bugs     

## 快速入門  

### 前置工作  
1. 在Godot資源商店搜索GMUI，點擊下載並導入插件  
> 也可以下載插件包`gmui.zip`手動導入  
2. 進入項目設置，啟用插件(勾選)  

### 最簡單的頁面  

在根目錄下的pages文件夾裏新建index.gmui文件，然後寫入：  

```xml


```  

運行項目，即可看到您寫的空白頁面。沒錯，什麽代碼都不需要寫，一個GMUI項目就運行起來啦！GMUI的出發點是盡可能的簡單，不需要書寫任何多余的代碼。  
> 如果提示需要主場景，請選擇`addons/gmui/dist/scenes/pages/index.tscn`或相應目錄的場景文件   

### 註冊登錄界面  

為了盡快拿出一個可供使用的版本，目前GMUI復用了Godot的內置節點作為組件。後期會提供更加好看的默認組件，也歡迎社區的朋友貢獻組件庫。接下來通過一個沒有實際功能的註冊登陸界面進行演示：

```xml
<Row align="center">
    <Column align="center">
        <Row>
            <Label text="用戶名"></Label>
            <LineEdit placeholder_text="請輸入用戶名"></LineEdit>
        </Row>
        <Row>
            <Label text="密碼"></Label>
            <LineEdit placeholder_text="請輸入密碼"></LineEdit>
        </Row>
        <Row>
            <Button text="登錄"></Button>
            <Button text="重置"></Button>
         </Row>
    </Column>
</Row>
```

運行項目可以看到類似的效果：  

![ShowPic](https://s1.ax1x.com/2023/06/14/pCnM956.png)

### 雙向數據綁定  

雙向數據綁定也是小菜一碟！若要書寫邏輯代碼，請在.gmui文件最下方的位置添加一個`Script`標簽。下方的案例中，點擊登錄按鈕就會打印用戶輸入的內容。  

```xml
<Row align="center">
    <Column align="center">
        <Row>
            <Label text="用戶名"></Label>
            <LineEdit placeholder_text="請輸入用戶名" g-model="username"></LineEdit>
        </Row>
        <Row>
            <Label text="密碼"></Label>
            <LineEdit placeholder_text="請輸入密碼" g-model="password"></LineEdit>
        </Row>
        <Row>
            <Button text="登錄" ref="loginBtn"></Button>
            <Button text="重置" ref="resetBtn"></Button>
         </Row>
    </Column>
</Row>

<Script>
@onready var data = await reactive({'username': 'name', 'password': '123'})
func _mounted():
    gmui.refs['loginBtn'].rnode.pressed.connect(
        func():
        print('username:', data.rget('username'))
        print('password:', data.rget('password'))
    )
    gmui.refs['resetBtn'].rnode.pressed.connect(
    func():
        data.rset('username', '')
        data.rset('password', '')
    )
func _updated():
    print('username:', data.rget('username'))
    print('password:', data.rget('password'))
</Script>
```

您還可以對組件使用雙向綁定：

```xml
<LineEdit g-model="text"></LineEdit>

<Script>
@onready var data = await reactive({'text': 'new text'})
</Script>
```

```xml
<Control>
    <Component g-model:text="text"></Component>
    <Label :text="text"></Label>
</Control>

<Script>
@import('Component', 'res://components/component.gmui')
@onready var data = await reactive({'text': 'my text'})
</Script>
```  

### 獲取、修改節點  

如果在普通節點聲明`ref`，將會獲得一個虛擬節點。您可以通過`mv.refs['name']`來獲取虛擬節點：  

```xml
<Control>
    <Label text="my text" ref="label"></Label>
</Control>

<Script>
func _mounted():
    print(gmui.refs['label'].rnode.text)
</Script>
```  

如果在組件聲明`ref`，將會獲得一個該組件的gmui實例：

```xml
<Control>
    <Label text="component text" ref="text1"></Label>
</Control>
```  

```xml
<Control>
    <UsernameInput ref="component"></UsernameInput>
</Control>

<Script>
@import('UsernameInput', 'res://components/username_input.gmui')
func _mounted():
    var component = gmui.refs['component'].refs['text1']
</Script>
```  

當您想執行節點內的方法時，請使用`exec_func`方法，參數為方法名以及參數數組：  

```xml
<Control>
    <Label text="my text" id="label"></Label>
</Control>

<Script>
func _mounted():
    gmui.refs['label'].exec_func('set_text', ['new text'])
</Script>
```  

> 註意：虛擬節點雖然有真實節點，但最好不要直接通過它修改真實節點的狀態，請調用`exec_func`或者綁定響應式數據！  

### 頁面跳轉

頁面跳轉可以使用`jump_to`方法，參數為page目錄下的`.gmui`文件路徑：

```xml
<Column align="center">
    <Row align="center">
        <Text text="my text"></Text>
    </Row>
    <Row align="center">
        <Button text="jump" ref="btn"></Button>
    </Row>
</Column>

<Script>
func _mounted():
    gmui.refs['btn'].rnode.pressed.connect(
        func():
            self.jump_to('res://pages/page2.gmui')
    )
</Script>
```  

### 列表渲染
當您想要通過數組來渲染一個列表時，可以在標簽上使用`g-for`指令：  

```xml   
<Row align="center">
    <Column align="center" g-for="text in textArr">
        <Label :text="text"></Label>
    </Column>
</Row>

<Script>
@onready var data = await reactive({'textArr': ['text1', 'text2', 'text3']})
</Script>
```   

同時，你也能在組件上使用`g-for`指令：  

```xml
<Row>
    <Component g-for="(item, index) in arr" :text="item"></Component>
</Row>

<Script>
@import('Component', 'res://components/component.gmui')
@onready var data = await reactive({'arr': [1,2,3,4]})
</Script>
```  

```xml
<Row>
    <Label :text="text"></Label>
</Row>

<Script>
</Script>
```  


### 條件渲染  
您可以使用`g-if`來顯示您想顯示的內容：  

```xml
<Control>
    <Label text="1" g-if="flag"></Label>
    <Label text="2" g-else-if="true"></Label>
    <Label text="3" g-else-if="true"></Label>
    <Label text="4" g-else="true"></Label>
</Control>

<Script>
@onready var data = await reactive({'flag': false})
</Script>
```  

### 插槽

#### 默認插槽  
您只要在定義組件時使用`slot`標簽，就可以在使用組件時直接寫入內容替換掉slot：  

```xml
<Row>
    <Component>
        <Label text="my text"></Label>
    </Component>
</Row>

<Script>
@import('Component', 'res://components/component.gmui')
</Script>
```   

```xml
<Row>
    <Slot></Slot>
</Row>

<Script>
</Script>
```  

效果等於：  

```xml
<Row>
    <Row>
        <Label text="my text"></Label>
    </Row>
</Row>
```   

#### 具名插槽  

如果您希望使用多個插槽，則需要使用具名插槽，在`slot`和`template`指定名稱即可：  

```xml
<Row>
    <Component>
        <Template #slot1="NULL">
            <Label text="my text1"></Label>
        </Template>
        <Template #slot2="NULL">
            <Label text="my text2"></Label>
        </Template>
    </Component>
</Row>

<Script>
@import('Component', 'res://components/component.gmui')
</Script>
```  

```xml
<Row>
    <Slot name="slot1"></Slot>
    <Slot name="slot2"></Slot>
</Row>

<Script>
</Script>
```  

#### 插槽傳參  

您可以在插槽聲明一個變量，然後在組件聲明一個變量來存儲所有在插槽的變量：  

```xml
<Row>
    <Component #default="props">
        <Label :text="props.text"></Label>
    </Component>
</Row>

<Script>
@import('Component', 'res://components/component.gmui')
</Script>
```   

```xml
<Row>
    <Slot text="my text"></Slot>
</Row>

<Script>
</Script>
```   

### 監聽屬性  
您可以使用`watch`監聽響應式數據：  

```xml
<Row align="center">
	<Column align="center">
		<LineEdit g-model="text"></LineEdit>
	</Column>
</Row>

<Script>
var data = await reactive({'text': 'text'})

func _ready():
	watch('text', change_text)

func change_text(newValue, oldValue):
	print(newValue, ',', oldValue)
</Script>
```

### 計算屬性  

當您需要對屬性進行計算時，可以使用`computed`：  

```xml  
<Row align="center">
	<Column align="center">
		<Label :text="fullName"></Label>
		<Button ref="btn" text="改名"></Button>
	</Column>
</Row>

<Script>
var data = await reactive({'firstName': '張', 'lastName': '四'})

func fullName():
	return data.rget('firstName') + data.rget('lastName')

func _ready():
	computed(fullName)

func _mounted():
	gmui.refs['btn'].rnode.pressed.connect(
		func():
			data.rset('firstName', '李')
	)
</Script>
```

### 條件編譯  

您可以在gmui中使用條件編譯來指定當前代碼要使用在哪些平臺：  

```xml  
#ifdef [Windows]
<Label text="Windows"></Label>
#endif

#ifdef [Android]
<Label text="Android"></Label>
#endif

<Script>
#ifdef [Windows]
var platform = 'Windows'
#endif
<Script>
```   

```xml  
#ifndef [Windows]
<Label text="Not Windows"></Label>
#endif

<Script>
#ifndef [Windows]
var platform = 'Not Windows'
#endif
</Script>
```   

### 修改項目信息

您可以在項目根目錄下找到`gmui.json`配置文件，並在該文件內配置項目的基本信息。比如：

1. 在`name`屬性中設置項目的名稱  
2. 在`version`屬性中設置版本號  
3. 在`icon`屬性中設置項目圖標  
4. 通過`gmui_index`屬性設置項目的入口文件  
5. 通過`screen`屬性設置默認的屏幕分辨率  

這些屬性修改完成後，會自動覆蓋Godot的項目設置，完成相關信息的修改。  

## 路線圖  

0. [x] 雙向數據綁定  
1. [ ] 全新的UI組件庫  
2. [ ] 更多的布局組件  
3. [ ] C# 語言支持  