# GoVM
Godot MVVM框架，帮助你更简单地开发UI。
注意，目前处于开发测试阶段。

使用说明：
1，入门

1），如果你需要创建新场景，必须在scenes文件夹下创建，并且需要使用我自定义的RootNode,RootNode2D,RootNode3D,RootContrl（注意，不知道为什么除了rootnode，其他节点不会自动挂脚本，需要手动挂），最后需要在layouts下创建xml文件，注意路径需要一一对应，如下：

![Screenshot 2023-06-05 171104](https://github.com/JustDooooIt/GoVM/assets/43512399/758ec2c1-eb21-4cd1-9daf-26e54bf3c191)![xml截图1](https://github.com/JustDooooIt/GoVM/assets/43512399/7ef4fb3e-28a9-423a-a39f-020b1092327b)

2），然后在xml写入节点

![xml截图2](https://github.com/JustDooooIt/GoVM/assets/43512399/73e3f7dc-7776-4fc6-a057-1fbad27139d4)

运行游戏即可看到新的节点被创建

2，单向数据绑定

1）你可以看到创建的场景的根节点有默认的脚本，你需要继承这个脚本。

2）然后你就可以在ready方法定义响应式数据了，如下：

![Screenshot 2023-06-05 172609](https://github.com/JustDooooIt/GoVM/assets/43512399/3a87a60d-aadb-44b8-8896-12ec2ae25a6f)

vm是位于父脚本的变量，是管理当前场景数据的实例。
vm.define_reactive可以将字典转换为响应式对象。
mounted方法会在ready之后执行，即组件渲染完成后执行。
updated方法会在你更改数据时执行。
3）最后在xml中使用g-bind获取数据即可

![xml截图3](https://github.com/JustDooooIt/GoVM/assets/43512399/803b9e61-b816-415d-b8f3-95869fcdb894)

4）如果要修改数据，则调用define_reactive返回的对象的rset,获取用rget

3，父子场景传值
1）首先使用Scene标签引入其他场景的xml文件，然后使用输入你要传递的参数

![截图4](https://github.com/JustDooooIt/GoVM/assets/43512399/2d0d3cbc-947a-43ca-85f9-ab40b1a5a580)

2）在子场景中使用g-bind获取变量

![xml截图4](https://github.com/JustDooooIt/GoVM/assets/43512399/a3d3bf8f-2a2b-42f9-aaea-bfa126ee5606)

4）如果子场景要给父场景传递参数，请使用signal
5）最后还有插槽，在子场景使用<Slot name="slot"></Slot>声明插槽，在Scene中使用<Template slot="slot"></Template>即可


当你看完这些，你可能会觉得十分甚至九分像vue，不用怀疑，总体思想就是vue来指导，底层细节不同而已（逃
