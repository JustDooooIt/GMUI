# GMUI - Godot MVVM UI
Godot游戏引擎的 MVVM UI 框架
> [English](https://github.com/JustDooooIt/GMUI)&nbsp;&nbsp;&nbsp;[中文文档](https://github.com/JustDooooIt/GMUI/blob/master/README.ZH.md)  
> 注意：目前处于早期开发阶段  
> 支持版本：4.x

## 快速开始

#### 简单使用

1. 新场景必须在根目录的`scenes`文件夹里创建，并且需要使用GMUI提供的`GNode`，`GNode2D`，`GNode3D`，`GControl`节点，然后在`layouts`文件夹里创建XML文件，示例如下：

![Screenshot 2023-06-05 171104](https://github.com/JustDooooIt/GoVM/assets/43512399/758ec2c1-eb21-4cd1-9daf-26e54bf3c191)  

```xml
<?xml version="1.0" encoding="UTF-8"?>

<Node2D name="MainScene">
</Node2D>
```

> 由于一个已知的bug，除`GNode`外，其他节点不会自动挂载脚本，需手动挂载  

2. 在XML文件中写入节点  

```xml
<?xml version="1.0" encoding="UTF-8"?>

<Node2D name="MainScene">
    <Node2D name="node1"></Node2D>
</Node2D>
```  

> 运行游戏即可看到，新的节点被自动创建

#### 单向数据绑定

1. 创建的场景的根节点有默认的脚本，您需要继承这个脚本

2. 在`ready`方法定义响应式数据，如下：

```gdscript
extends "res://addons/gmui/scripts/common/g_node_2d.gd"

@onready var data = vm.define_reactive({'visible': false, 'text': 'text'})
    
func _mounted():
    await get_tree().create_timer(5).timeout
    data.rset('visible', true)
    print('mounted')

func _updated():
    print('updated')
```  

> `vm`是位于父脚本的变量，是管理当前场景数据的实例  

> `vm.define_reactive`可以将字典转换为响应式对象  

> `mounted`方法会在ready之后执行，即组件渲染完成后执行  

> `updated`方法会在你更改数据时执行    

3. 最后，在XML中使用`g-bind`指令获取数据即可  

```xml
<?xml version="1.0" encoding="UTF-8"?>

<Node2D name="MainScene">
    <Node2D name="node1" g-bind:visible="visible"></Node2D>
</Node2D>
```  

4. 如果要修改数据，可以调用`define_reactive`返回的对象的`rset`，获取则使用`rget`  

```gdscript  
var data = vm.define_reactive({'name': value})
data.rset('name', newValue)
var v = data.rget('name')
```  

#### 父子场景传值  

1. 首先使用`Scene`标签引入其他场景的XML文件，然后输入您要传递的参数  

```xml
<?xml version="1.0" encoding="UTF-8"?>

<Node2D name="MainScene">
    <Scene name="SubScene1" scene_xml_path="res://layouts/sub_scene1.xml" visible="true"></Scene>
</Node2D>
```  

2. 在子场景中使用`g-bind`指令获取变量  

```xml
<?xml version="1.0" encoding="UTF-8"?>

<Node2D name="SubScene1">
    <Node2D name="node1" g-bind:visible="visible"></Node2D>
</Node2D>
```  

3. 在子场景中向父场景传递参数，可以使用signal  

```gdscript
extends "res://addons/gmui/scripts/common/g_node_2d.gd"

signal send_value(value)

func _ready():
    var parent = self.get_parent()
    send_value.connect(parent.set_value)
    
func _mounted():
    emit_signal('send_value', 10)
```  

```gdscript   
extends "res://addons/gmui/scripts/common/g_node_2d.gd"

var value

@onready var data = vm.define_reactive({'value':10})

func _mounted():
    print('mounted')

func _updated():
    print('updated')

func set_value(value):
    data.rset('value', value)
```   

4. 最后关于插槽的用法，示例如下    

```xml
<?xml version="1.0" encoding="UTF-8"?>

<Scene name="SubScene2" scene_xml_path="res://layouts/sub_scene2.xml">
    <Template>
        <Node2D name="node"></Node2D>
    </Template>
</Scene>
```  

```xml
<?xml version="1.0" encoding="UTF-8"?>

<Node2D name="SubScene2">
    <Slot></Slot>
</Node2D>
```  

> 看完这些，您可能会觉得十分甚至九分像Vue，事实也正是如此

## 路线图
1. [x] 单向数据绑定  
2. [ ] 双向数据绑定  
3. [ ] C# 语言支持  
4. [ ] 声明式UI  
5. [ ] ...  
