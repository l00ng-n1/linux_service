# 数据的分类

## 结构化数据

结构化数据是指具有固定格式或模型的数据，通常存储在关系型数据库（RDBMS）中。这类数据具有清晰的字段名称和数据类型，并且可以使用SQL语言进行查询和操作。

对于结构化数据来讲通常是先有结构再有数据。

**特点：**

-   数据呈表格形式（行和列）。
-   具有固定的架构（Schema）。
-   易于存储、查询和管理。

**存储方式：**

-   MySQL
-   PostgreSQL
-   Oracle数据库

## 半结构化数据

半结构化数据是指数据不具有严格的表格结构，但有一定的组织方式或标签标记，便于解析和分析。这类数据介于结构化数据和非结构化数据之间。

**特点：**

-   不需要固定的架构。
-   数据包含自描述信息（如标签、元数据）。
-   通常使用键值对、文档格式或树状结构存储。

**示例：**

-   XML文件
-   JSON数据
-   NoSQL数据库中的数据（如MongoDB、Couchbase）
-   日志文件

**存储方式：**

-   MongoDB
-   Elasticsearch
-   Hadoop HDFS（部分场景）

## 非结构化数据

非结构化数据是指没有固定格式或模型的数据。这类数据通常以二进制或原始形式存在，难以直接分类或存储在关系型数据库中。

**特点：**

-   缺乏固定的结构和模式。
-   数据量通常较大。
-   分析和处理复杂。

**示例：**

-   图像（如JPG、PNG）
-   音频（如MP3、WAV）
-   视频（如MP4、AVI）
-   文本文件（如PDF、Word文档）
-   社交媒体内容（如推文、评论）

**存储方式：**

-   分布式文件系统（如Hadoop HDFS、Amazon S3）
-   对象存储服务（如Ceph、MinIO）
-   专用多媒体数据库（如GridFS）

# 数据库管理系统

## 相关概念

*   数据库：Database(DB)

数据库是按照一定的数据结构来组织，存储和管理数据的仓库。是一个长期存储在计算机内的、有组织 的、可共享的、统一管理的大量数据的集合。



*   数据库管理系统：Database Management System (DBMS)

数据库管理系统是一种操纵和管理数据库的大型软件，用于建立，使用和维护数据库，简称 DBMS。 它对数据库进行统一的管理和控制，以保证数据库的安全性和完整性。



*   数据库管理员：Database Administrator (DBA)

DBA 是从事管理和维护数据库管理系统(DBMS)的相关工作人员的统称，属于运维工程师的一个分支，主 要负责业务数据库从设计、测试到部署交付的全生命周期管理。

DBA 的核心目标是保证数据库管理系统的稳定性、安全性、完整性和高可用性能。



*   应用程序：Application 

一个应用程序通常是指能够执行某种功能的软件程序。



##  数据库管理系统特点

*   数据库管理系统中采用了复杂的数据模型表示数据结构，数据冗余小，易扩充，实现了数据共享。
*   具有较高的数据和程序独立性。 
    *   数据库的独立性表现在物理独立性和逻辑独立性两个方面。
*   数据库管理系统为用户和应用程序提供了方便和统一的查询接口。
*   数据库管理系统的存在，使得数据可以和应用程序解耦。
*   数据库管理系统还具有并发控制，数据备份和恢复，完整性和安全性保障等功能。

## 数据库管理系统基本功能

*   数据的定义

DBMS 提供了数据定义语言 DDL（Data Definition Language），供用户定义数据库的三级模式结 构，两级映像以及完整性约束和保密限制等约束。DDL主要用于建立、修改数据库的库结构。DDL所描述的库结 构仅仅给出了数据库的框架，数据库的框架信息被存放在数据字典中。



*   数据操作

DBMS提供数据操作语言 DML （Data Manipulation Language），供用户实现对数据的追加、删 除、更新、查询等操作。



*   数据组织、存储与管理

DBMS要分类组织、存储和管理各种数据，包括数据字典、用户数据、存取路径等，需确定以何种文件结 构和存取方式在存储级上组织这些数据，如何实现数据之间的联系。数据组织和存储的基本目标是提高存储空 间利用率，选择合适的存取方法提高存取效率。



*   数据库的运行管理

数据库的运行管理功能是DBMS的运行控制、管理功能，包括多用户环境下的并发控制、安全性检查和存 取限制控制、完整性检查和执行、运行日志的组织管理、事务的管理和自动恢复，即保证事务的原子性。这些 功能保证了数据库系统的正常运行。



*   数据库的维护

这一部分包括数据库的数据载入、转换、转储、数据库的重组和重构以及性能监控等功能，这些功能分别 由各个使用程序来完成。



*   数据库的保护

数据库中的数据是信息社会的战略资源，所以数据的保护至关重要。DBMS对数据库的保护通过4个方面来 实现：数据库的恢复、数据库的并发控制、数据库的完整性控制、数据库安全性控制。DBMS的其他保护功能还 有系统缓冲区的管理以及数据存储的某些自适应调节机制等。



*   通信

DBMS具有与操作系统的联机处理、分时系统及远程作业输入的相关接口，负责处理数据的传送。对网络 环境下的数据库系统，还应该包括DBMS与网络中其他软件系统的通信功能以及数据库之间的互操作功能。



# 关系型数据库理论

##  E-R模型

**E-R模型的基本构成要素**

*   **实体（Entity）**：
    *   表示现实世界中可区分的对象或事物，如学生、课程、产品等。
    *   在E-R图中，实体通常用矩形表示，矩形内写上实体的名称。

*   **属性（Attribute）**：
    *   描述实体的特征或性质，如学生的姓名、学号，课程的名称、编号等。
    *   在E-R图中用椭圆形表示，并通过线条与相应的实体相连。

*   **联系（Relationship）**：
    *   表示实体之间的关联，如学生选修课程、员工管理项目等。
    *   在E-R图中用菱形表示，并通过线条连接相关的实体。



## 联系类型

**类型：**

1.  一对一关系 (1:1)
    -   一个实体的一个实例与另一个实体的一个实例相关联。
    -   例如：一个人对应一个身份证。
2.  一对多关系 (1:N)
    -   一个实体的一个实例可以与另一个实体的多个实例相关联。
    -   例如：一个部门有多个员工。
3.  多对多关系 (M:N)
    -   一个实体的多个实例可以与另一个实体的多个实例相关联。
    -   例如：学生和课程之间的关系。



## 数据的操作

数据库中对数据的操作主要包括增删改查

![image-20241227174457836](pic/image-20241227174457836.png)

## 数据库六范式

目前关系数据库有六种范式：第一范式（1NF）、第二范式（2NF）、第三范式（3NF）、巴德斯科范式 （BCNF）、第四范式(4NF）和第五范式（5NF，又称完美范式）。

满足最低要求的范式是第一范式（1NF）。 在第一范式的基础上进一步满足更多规范要求的称为第二范式（2NF），其余范式以次类推。一般数据库只需 满足第三范式(3NF）即可。

### 第一范式 1NF (确保每列保持原子性)

第一范式是最基本的范式。如果数据库表中的所有字段值都是不可分解的原子值，就说明该数据库表满足 了第一范式。

其核心是要保证数据表中的列里面没有重复值，

*   即实体中的某个属性不能有多个值或者不能有重复的属性，确保每一列的原子性

**不满足 1NF 的例子：**

一个“学生”表：

| **学号 (SID)** | **姓名 (Name)** | **电话 (Phone)** | **课程 (Courses)** |
| -------------- | --------------- | ---------------- | ------------------ |
| 001            | 张三            | 123456, 789012   | 数学, 英语         |
| 002            | 李四            | 987654           | 物理, 化学, 生物   |

**满足 1NF 的例子：**

将表拆分为符合 1NF 的形式：

| **学号 (SID)** | **姓名 (Name)** | **电话 (Phone)** | **课程 (Course)** |
| -------------- | --------------- | ---------------- | ----------------- |
| 001            | 张三            | 123456           | 数学              |
| 001            | 张三            | 789012           | 英语              |
| 002            | 李四            | 987654           | 物理              |
| 002            | 李四            | 987654           | 化学              |
| 002            | 李四            | 987654           | 生物              |

###  第二范式 2NF (确保表中的每列都和主键相关)

**2NF 的定义：**

-   **前提：必须满足 1NF**。
-   关键要求：表中的每一个非主键字段必须完全依赖于主键，不能依赖于主键的一部分。
    -   如果主键是单字段，表在 1NF 的情况下自然满足 2NF。
    -   如果主键是**复合主键**（由多个字段组成），则需要检查非主键字段是否依赖于主键的全部字段，而不是只依赖于主键的一部分。

**违反 2NF 的情况：**

假设一个表记录了学生选课的信息，主键由 `Student_ID` 和 `Course_ID` 组成：

| **Student_ID** | **Course_ID** | **Student_Name** | **Course_Name** | **Grade** |
| -------------- | ------------- | ---------------- | --------------- | --------- |
| 1              | 101           | 张三             | 数据库          | 85        |
| 1              | 102           | 张三             | 网络技术        | 90        |
| 2              | 101           | 李四             | 数据库          | 88        |

**问题分析：**

1.  主键：
    -   `Student_ID + Course_ID` 是复合主键，用于唯一标识每一条记录。
2.  非主键字段：
    -   `Student_Name`：仅依赖于 `Student_ID`。
    -   `Course_Name`：仅依赖于 `Course_ID`。
    -   `Grade`：完全依赖于 `Student_ID + Course_ID`。

**优化建议**

**解决方法：分解表结构**

将表分解为多个小表，消除非主属性对部分主键的依赖，达到第二范式 (2NF) 的要求。

**分解后的表结构：**

1.  **学生表 (Students)**：

    | **Student_ID** | **Student_Name** |
    | -------------- | ---------------- |
    | 1              | 张三             |
    | 2              | 李四             |

    -   记录每个学生的基本信息。
    -   `Student_ID` 是主键。

2.  **课程表 (Courses)**：

    | **Course_ID** | **Course_Name** |
    | ------------- | --------------- |
    | 101           | 数据库          |
    | 102           | 网络技术        |

    -   记录每门课程的基本信息。
    -   `Course_ID` 是主键。

3.  **选课表 (Student_Course)**：

    | **Student_ID** | **Course_ID** | **Grade** |
    | -------------- | ------------- | --------- |
    | 1              | 101           | 85        |
    | 1              | 102           | 90        |
    | 2              | 101           | 88        |

    -   记录学生和课程的对应关系，以及成绩。
    -   `Student_ID + Course_ID` 是复合主键。

### 第三范式 3NF (确保每列都和主键列直接相关，而不是间接相关)

**定义**

1.  **前提：必须满足第二范式 (2NF)**。
2.  要求：非主属性不能传递依赖于主键。
    -   **传递依赖**：如果非主属性 `A` 依赖于非主属性 `B`，而 `B` 又依赖于主键 `K`，则称 `A` 传递依赖于主键 `K`。
    -   在 3NF 中，所有非主属性必须直接依赖于主键，而不能通过其他非主属性间接依赖主键。

**问题分析**

以如下学生选课表为例：

| **Student_ID** | **Student_Name** | **Class** | **Department** |
| -------------- | ---------------- | --------- | -------------- |
| 1              | 张三             | 1班       | 计算机系       |
| 2              | 李四             | 2班       | 电子系         |
| 3              | 王五             | 3班       | 计算机系       |

主键：

`Student_ID` 是主键。

问题：

-   `Class` 和 `Department` 都依赖于主键 `Student_ID`。
-   但实际上，`Department` 是通过 `Class` 确定的，存在如下传递依赖：
    -   `Student_ID → Class → Department`

这种设计会引发以下问题：

1.  数据冗余：
    -   同一个班级的系信息（如 `1班` 是 `计算机系`）会重复存储多次。
2.  更新异常：
    -   如果班级对应的系信息发生变更（如 `1班` 改为 `信息系`），需要更新多条记录，容易遗漏。
3.  插入异常：
    -   如果想新增一个班级（如 `4班` 是 `机械系`），但没有学生时，无法插入。
4.  删除异常：
    -   删除所有学生后，班级和系的信息也会丢失。

**解决方法：分解表结构**

为消除传递依赖，可以将表分解为两张表：

1.  **学生表 (Students)**：

    | **Student_ID** | **Student_Name** | **Class** |
    | -------------- | ---------------- | --------- |
    | 1              | 张三             | 1班       |
    | 2              | 李四             | 2班       |
    | 3              | 王五             | 3班       |

    -   `Student_ID` 是主键。
    -   每个学生直接关联班级信息。

2.  **班级-系表 (Class_Department)**：

    | **Class** | **Department** |
    | --------- | -------------- |
    | 1班       | 计算机系       |
    | 2班       | 电子系         |
    | 3班       | 计算机系       |

    -   `Class` 是主键。
    -   每个班级直接对应所属系信息。

### 巴德斯科范式 （BCNF）

在 BCNF 中，要求表的每一个**决定因素**都是一个候选键。BCNF 解决了某些情况下，第三范式依然可能出现的问题，例如**依赖冲突**或**非主属性依赖于主键以外的候选键**。

**定义**

1.  **前提：必须满足第三范式 (3NF)**。
2.  要求：表中的每个决定因素都是候选键。
    -   **决定因素**（Determinant）：指在函数依赖中，可以唯一确定其他属性的一个属性或一组属性。例如，`A → B` 中，`A` 是决定因素。
    -   **候选键**（Candidate Key）：唯一标识表中每条记录的一组属性。

**例子：不满足 BCNF 的表**

以下是一个学生-课程表：

| **Student_ID** | **Course_ID** | **Instructor** | **Instructor_Office** |
| -------------- | ------------- | -------------- | --------------------- |
| 1              | 101           | 张三           | A101                  |
| 2              | 101           | 张三           | A101                  |
| 3              | 102           | 李四           | B202                  |
| 4              | 103           | 王五           | C303                  |

**候选键分析**：

1.  主键是 `Student_ID + Course_ID`，它可以唯一标识每条记录。
2.  存在以下函数依赖：
    -   `Student_ID + Course_ID → Instructor, Instructor_Office` （主键的完全依赖）
    -   `Instructor → Instructor_Office` （Instructor 决定了 Instructor_Office）

**问题**：

`Instructor → Instructor_Office` 表示 `Instructor` 是一个决定因素，但 `Instructor` 并不是候选键，因为它不能唯一标识表中的每条记录。

因此，这张表不满足 BCNF，因为存在非候选键（Instructor）作为决定因素。

**解决方法：分解表结构**

为满足 BCNF，需要对表进行分解，消除 `Instructor → Instructor_Office` 的异常。

分解后的表：

1.  **学生-课程表 (Student_Course)**：

    | **Student_ID** | **Course_ID** | **Instructor** |
    | -------------- | ------------- | -------------- |
    | 1              | 101           | 张三           |
    | 2              | 101           | 张三           |
    | 3              | 102           | 李四           |
    | 4              | 103           | 王五           |

    -   `Student_ID + Course_ID` 是主键。

2.  **教师信息表 (Instructor_Info)**：

    | **Instructor** | **Instructor_Office** |
    | -------------- | --------------------- |
    | 张三           | A101                  |
    | 李四           | B202                  |
    | 王五           | C303                  |

    -   `Instructor` 是主键。

### 第四范式 (4NF - Fourth Normal Form)

**第四范式 (4NF)** 是数据库规范化中的更高一级范式，旨在消除**多值依赖 (Multivalued Dependency)**，解决多值属性之间的冗余和异常问题。

**定义**

1.  **前提：必须满足 BCNF**（Boyce-Codd范式）。
2.  要求：表中不存在非平凡的多值依赖。
    -   **非平凡多值依赖**（Non-Trivial Multivalued Dependency）： 在一个关系中，如果某个属性组 `A` 决定了一组属性 `B`，且 `B` 与 `A` 无关的其他属性之间也存在多个值的组合，则称为多值依赖。
    -   在 4NF 中，任何多值依赖必须由候选键决定。

**4NF 的重点是：每张表只表示一个独立的关系。**

**多值依赖问题示例**

示例表：

| **Student_ID** | **Course** | **Hobby** |
| -------------- | ---------- | --------- |
| 1              | 数据库     | 篮球      |
| 1              | 数据库     | 足球      |
| 1              | 网络技术   | 篮球      |
| 1              | 网络技术   | 足球      |

**分析：**

-   学生选课 (`Student_ID → Course`) 和学生兴趣 (`Student_ID → Hobby`) 是两个独立的属性组。
-   但 `Course` 和 `Hobby` 之间并无直接联系，导致数据出现**笛卡尔积**（每个课程与每个兴趣都组合起来存储）。

**问题：**

1.  数据冗余：
    -   学生的兴趣和课程是独立的，但在表中每个兴趣和每门课程都重复存储，造成大量冗余。
2.  更新异常：
    -   如果新增学生的兴趣（如 `乒乓球`），需要为每门课程都新增一条记录，容易出错。
3.  插入异常：
    -   如果某学生还没有课程信息，但有兴趣，则无法插入该兴趣信息。
4.  删除异常：
    -   删除某学生的所有课程信息后，该学生的兴趣信息也会丢失。

**解决方法：分解表结构**

为消除多值依赖，可以将表分解为两个独立的表：

1.   学生-课程表：

| **Student_ID** | **Course** |
| -------------- | ---------- |
| 1              | 数据库     |
| 1              | 网络技术   |

2.   学生-兴趣表：

| **Student_ID** | **Hobby** |
| -------------- | --------- |
| 1              | 篮球      |
| 1              | 足球      |

### 第五范式 (5NF - Fifth Normal Form)

**第五范式 (5NF)**，也称为**投影连接范式 (PJ/NF - Projection-Join Normal Form)**，是数据库规范化的最高级范式之一。它的目标是消除因**连接依赖 (Join Dependency)** 导致的冗余和异常，确保表结构没有多余的分组依赖。

**定义**

1.  **前提：必须满足第四范式 (4NF)**。
2.  要求：表中的数据不能因某些连接依赖 (Join Dependency) 而导致数据冗余。
    -   如果一个表可以被分解为两个或多个子表，通过自然连接（Natural Join）重新合并时不会丢失数据，则表具有连接依赖。
    -   如果这种分解会引入冗余，则表不满足 5NF。

简而言之，**5NF 的目标是消除所有不必要的连接依赖，避免冗余数据**。



**举例说明**

假设有以下项目分配表，表示员工在某个项目中与某个供应商的协作：

| **Employee_ID** | **Project_ID** | **Vendor_ID** |
| --------------- | -------------- | ------------- |
| 1               | A              | X             |
| 1               | A              | Y             |
| 2               | A              | X             |
| 2               | B              | X             |
| 3               | B              | X             |
| 3               | B              | Z             |

**主键分析**

-   **主键**：`Employee_ID + Project_ID + Vendor_ID` 是复合主键。
-   关系表示：
    -   一个员工可能在某个项目中与多个供应商协作。
    -   不同员工可能在同一个项目中与不同供应商协作。

**问题分析**

表中的一些信息实际上是**由多个独立关系组合而成的**，并存在如下冗余：

1.  冗余信息：
    -   例如，`Employee_ID = 1` 与 `Vendor_ID = X` 和 `Vendor_ID = Y` 的关系是通过 `Project_ID = A` 隐式建立的。
    -   但表中显式存储了所有组合关系，导致数据重复。
2.  插入异常：
    -   如果员工与供应商之间的关系还未明确某个项目，插入这些数据会很困难。
3.  删除异常：
    -   如果某个员工在所有项目中与某个供应商的协作关系被删除，可能会丢失该员工与供应商之间的整体关系信息。

**解决方法：分解表结构**

将表分解为以下三个独立的表：

1. **员工-项目表 (Employee_Project)**：

| **Employee_ID** | **Project_ID** |
| --------------- | -------------- |
| 1               | A              |
| 2               | A              |
| 2               | B              |
| 3               | B              |

2. **项目-供应商表 (Project_Vendor)**：

| **Project_ID** | **Vendor_ID** |
| -------------- | ------------- |
| A              | X             |
| A              | Y             |
| B              | X             |
| B              | Z             |

3. **员工-供应商表 (Employee_Vendor)**：

| **Employee_ID** | **Vendor_ID** |
| --------------- | ------------- |
| 1               | X             |
| 1               | Y             |
| 2               | X             |
| 3               | X             |
| 3               | Z             |

**重建原始表**

可以通过自然连接以下三个表重新得到原始关系：

```sql
SELECT Employee_Project.Employee_ID, 
       Employee_Project.Project_ID, 
       Project_Vendor.Vendor_ID
FROM Employee_Project
JOIN Project_Vendor 
  ON Employee_Project.Project_ID = Project_Vendor.Project_ID
JOIN Employee_Vendor 
  ON Employee_Project.Employee_ID = Employee_Vendor.Employee_ID;
```

### 反范式化

有的时候不能简单按照规范要求设计数据表，因为有的数据看似冗余，其实对业务来说十分重要。这个时候，我们就要遵循业务优先的原则，首先满足业务需求，再尽量减少冗余。

如果数据库中的数据量比较大，系统的UV和PV访问频次比较高，则完全按照MySQL的三大范式设计数据表，读数据时会产生大量的关联查询，在一定程度上会影响数据库的读性能。如果我们想对查询效率进行优化，反范式优化也是一种优化思路。此时，可以通过在数据表中增加冗余字段来提高数据库的读性能。

