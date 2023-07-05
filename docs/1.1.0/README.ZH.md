# GMUI - Godot MVgmui UI  
Godot游戏引擎的 MVgmui UI框架   
> [English](https://github.com/JustDooooIt/GMUI)&nbsp;&nbsp;&nbsp;[中文文档](https://github.com/JustDooooIt/GMUI/blob/master/README.ZH.md)   
> GMUI版本：1.0.0   &nbsp;&nbsp;&nbsp;&nbsp;Godot版本：4.x  

## 快速入门  

### 前置工作  
1. 在Godot资源商店搜索GMUI，点击下载并导入插件  
> 也可以下载插件包`gmui.zip`手动导入  
2. 进入项目设置，启用插件(勾选)  

### 最简单的页面  
在根目录下的pages文件夹里新建index.gmui文件，然后写入：  

```xml



```  

运行项目，即可看到你写的空白页面。没错，你什么代码都不需要写，一个GMUI项目就运行起来啦！GMUI的出发点是尽可能的简单，不需要书写任何多余的代码。  
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
@onready var data = gmui.reactive({'text': 'my text'})
</Script>

### 获取、修改节点  
如果在普通节点声明ref，将会获得一个虚拟节点。您可以通过`mv.refs['name']`来获取虚拟节点

```xml
<Control>
    <Label text="my text" ref="label"></Label>
</Control>

<Script>
func _mounted():
	print(gmui.refs['label'].rnode.text)
</Script>
```

如果在组件声明ref，将会获得一个该组件的gmui实例：

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

当您想执行节点内的方法时，请使用exec_func方法，参数为方法名以及参数数组：

```xml
<Control>
    <Label text="my text" id="label"></Label>
</Control>

<Script>
func _mounted():
	gmui.refs['label'].exec_func('set_text', ['new text'])
</Script>
```

> 注意：虚拟节点虽然有真实节点，但最好不要直接通过它修改真实节点的状态，请调用exec_func或者绑定响应式数据！  

### 页面跳转

页面跳转可以使用jump_to方法，参数为page目录下的.gmui文件路径：

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
当您想要通过数组来渲染一个列表时，可以在标签上使用g-for指令
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
同时，你也能在组件上使用g-for指令
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
您可以使用g-if来显示您想显示的内容
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

###插槽

默认插槽
您只要在定义组件时使用slot标签，就可以在使用组件时直接写入内容替换调slot
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
效果等于
```xml
<Row>
	<Row>
	    <Label text="my text"></Label>
    </Row>
</Row>
```

具名插槽
如果您希望使用多个插槽，则需要使用具名插槽，在slot和template指定名称即可
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

插槽传参
您可以在插槽声明一个变量，然后在组件声明一个变量来存储所有在插槽的变量
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

## 路线图  

0. [x] 双向数据绑定  
1. [ ] 全新的UI组件库  
2. [ ] 更多的布局组件  
3. [ ] C# 语言支持  