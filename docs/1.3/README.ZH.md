# GMUI - Godot MVVM UI  
Godot游戏引擎的 MVVM UI框架   

> [English](https://github.com/JustDooooIt/GMUI)&nbsp;&nbsp;&nbsp;[简体中文](https://github.com/JustDooooIt/GMUI/blob/master/README.ZH.md)&nbsp;&nbsp;&nbsp;[繁体中文](https://github.com/JustDooooIt/GMUI/blob/master/README.ZH-TW.md)   
> GMUI版本：1.3.x   &nbsp;&nbsp;&nbsp;&nbsp;Godot版本：4.x  

> 最新情报  
> 1.3版本更新内容:    
>> 1. 新增监听属性   
>> 2. 新增计算属性   
>> 3. 新增条件编译   
>> 4. 修复了已知bugs   

## 快速入门  

### 前置工作  
1. 在Godot资源商店搜索GMUI，点击下载并导入插件  
> 也可以下载插件包`gmui.zip`手动导入  
2. 进入项目设置，启用插件(勾选)  

### 最简单的页面  

在根目录下的pages文件夹里新建index.gmui文件，然后写入：  

```xml


```  

运行项目，即可看到您写的空白页面。没错，什么代码都不需要写，一个GMUI项目就运行起来啦！GMUI的出发点是尽可能的简单，不需要书写任何多余的代码。  
> 如果提示需要主场景，请选择`addons/gmui/dist/scenes/pages/index.tscn`或相应目录的场景文件   

### 注册登录界面  

为了尽快拿出一个可供使用的版本，目前GMUI复用了Godot的内置节点作为组件。后期会提供更加好看的默认组件，也欢迎社区的朋友贡献组件库。接下来通过一个没有实际功能的注册登陆界面进行演示：

```xml
<Row align="center">
    <Column align="center">
        <Row>
            <Label text="用户名"></Label>
            <LineEdit placeholder_text="请输入用户名"></LineEdit>
        </Row>
        <Row>
            <Label text="密码"></Label>
            <LineEdit placeholder_text="请输入密码"></LineEdit>
        </Row>
        <Row>
            <Button text="登录"></Button>
            <Button text="重置"></Button>
         </Row>
    </Column>
</Row>
```

运行项目可以看到类似的效果：  

![ShowPic](https://s1.ax1x.com/2023/06/14/pCnM956.png)

### 双向数据绑定  

双向数据绑定也是小菜一碟！若要书写逻辑代码，请在.gmui文件最下方的位置添加一个`Script`标签。下方的案例中，点击登录按钮就会打印用户输入的内容。  

```xml
<Row align="center">
    <Column align="center">
        <Row>
            <Label text="用户名"></Label>
            <LineEdit placeholder_text="请输入用户名" g-model="username"></LineEdit>
        </Row>
        <Row>
            <Label text="密码"></Label>
            <LineEdit placeholder_text="请输入密码" g-model="password"></LineEdit>
        </Row>
        <Row>
            <Button text="登录" ref="loginBtn"></Button>
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

您还可以对组件使用双向绑定：

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

### 获取、修改节点  

如果在普通节点声明`ref`，将会获得一个虚拟节点。您可以通过`mv.refs['name']`来获取虚拟节点：  

```xml
<Control>
    <Label text="my text" ref="label"></Label>
</Control>

<Script>
func _mounted():
    print(gmui.refs['label'].rnode.text)
</Script>
```  

如果在组件声明`ref`，将会获得一个该组件的gmui实例：

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

当您想执行节点内的方法时，请使用`exec_func`方法，参数为方法名以及参数数组：  

```xml
<Control>
    <Label text="my text" id="label"></Label>
</Control>

<Script>
func _mounted():
    gmui.refs['label'].exec_func('set_text', ['new text'])
</Script>
```  

> 注意：虚拟节点虽然有真实节点，但最好不要直接通过它修改真实节点的状态，请调用`exec_func`或者绑定响应式数据！  

### 页面跳转

页面跳转可以使用`jump_to`方法，参数为page目录下的`.gmui`文件路径：

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
当您想要通过数组来渲染一个列表时，可以在标签上使用`g-for`指令：  

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

同时，你也能在组件上使用`g-for`指令：  

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


### 条件渲染  
您可以使用`g-if`来显示您想显示的内容：  

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

#### 默认插槽  
您只要在定义组件时使用`slot`标签，就可以在使用组件时直接写入内容替换掉slot：  

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

效果等于：  

```xml
<Row>
    <Row>
        <Label text="my text"></Label>
    </Row>
</Row>
```   

#### 具名插槽  

如果您希望使用多个插槽，则需要使用具名插槽，在`slot`和`template`指定名称即可：  

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

#### 插槽传参  

您可以在插槽声明一个变量，然后在组件声明一个变量来存储所有在插槽的变量：  

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

### 监听属性  
您可以使用`watch`监听响应式数据：  

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

### 计算属性  

当您需要对属性进行计算时，可以使用`computed`：  

```xml  
<Row align="center">
	<Column align="center">
		<Label :text="fullName"></Label>
		<Button ref="btn" text="改名"></Button>
	</Column>
</Row>

<Script>
var data = await reactive({'firstName': '张', 'lastName': '四'})

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

### 条件编译  

您可以在gmui中使用条件编译来指定当前代码要使用在哪些平台：  

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

### 修改项目信息

您可以在项目根目录下找到`gmui.json`配置文件，并在该文件内配置项目的基本信息。比如：

1. 在`name`属性中设置项目的名称  
2. 在`version`属性中设置版本号  
3. 在`icon`属性中设置项目图标  
4. 通过`gmui_index`属性设置项目的入口文件  
5. 通过`screen`属性设置默认的屏幕分辨率  

这些属性修改完成后，会自动覆盖Godot的项目设置，完成相关信息的修改。  

## 路线图  

0. [x] 双向数据绑定  
1. [ ] C# 语言支持   
2. [ ] Material Design UI  