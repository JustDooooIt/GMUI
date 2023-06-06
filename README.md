# GMUI - Godot MVVM UI  
Godot Engine MVVM UI  
> [English](https://github.com/JustDooooIt/GMUI)&nbsp;&nbsp;&nbsp;[中文文档](https://github.com/JustDooooIt/GMUI/blob/master/README.ZH.md)  
> PS：GMUI is currently in the early stages of development .    

## Quick Start

#### Easy to use

1. New scenes must be created in the `scenes` folder in the root directory and need to use the `GNode`, `GNode2D`, `GNode3D`, `GControl` nodes provided by GMUI, then create XML files in the `layouts` directory, examples are as follows:

![Screenshot 2023-06-05 171104](https://github.com/JustDooooIt/GoVM/assets/43512399/758ec2c1-eb21-4cd1-9daf-26e54bf3c191)  

```xml
<?xml version="1.0" encoding="UTF-8"?>

<Node2D name="MainScene">
</Node2D>
```

> Due to a known bug, nodes other than `GNode` will not mount the script automatically, you need to mount it manually  

2. Create a node in the XML file  

```xml
<?xml version="1.0" encoding="UTF-8"?>

<Node2D name="MainScene">
    <Node2D name="node1"></Node2D>
</Node2D>
```  

> Run the game and see that new nodes are created automatically

#### One-way data binding

1. The root node of the created scene has a default script, which your node need to inherit

2. Define the responsive data in the `ready` method, as follows:

```gdscript
extends "res://addons/gmui/scripts/common/root_node_2d.gd"

@onready var data = vm.define_reactive({'visible': false, 'text': 'text'})
    
func _mounted():
    await get_tree().create_timer(5).timeout
    data.rset('visible', true)
    print('mounted')

func _updated():
    print('updated')
```  

> vm is a variable that belongs to the parent script and is the instance that manages the current scene data  
> vm.define_reactive converts the dictionary to a responsive object  

> mounted method will be executed after ready, i.e. after the component has finished rendering  
> the updated method will be executed when you change the data    

3. Finally, just use the `g-bind` directive in the XML to get the data  

```xml
<?xml version="1.0" encoding="UTF-8"?>

<Node2D name="MainScene">
    <Node2D name="node1" g-bind:visible="visible"></Node2D>
</Node2D>
```  

4. If you want to modify the data, you can call the `rset` of the object returned by `define_reactive`, and use `rget` for fetching  

```gdscript  
var data = vm.define_reactive({'name': value})
data.rset('name', newValue)
var v = data.rget('name')
```  

#### Passing values from parent to child scenes  

1. First use the `Scene` tag to bring in the XML file of the other scene, then enter the parameters you want to pass  

```xml
<?xml version="1.0" encoding="UTF-8"?>

<Node2D name="MainScene">
    <Scene name="SubScene1" scene_xml_path="res://layouts/sub_scene1.xml" visible="true"></Scene>
</Node2D>
```  

2. Use the `g-bind` directive in the sub-scene to get the variables  

```xml
<?xml version="1.0" encoding="UTF-8"?>

<Node2D name="SubScene1">
    <Node2D name="node1" g-bind:visible="visible"></Node2D>
</Node2D>
```  

3. Passing arguments to the parent scene in the child scene can be done using signal  

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

4. Finally, regarding the usage of slots, the example is as follows    

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

> After reading this, you might think GMUI is a lot like Vue, and that's exactly what it is

## Roadmap
1. [x] One-way Data Binding  
2. [ ] Two-way Data Binding  
3. [ ] C# Language Support  
4. [ ] Declarative UI  
5. [ ] ...  