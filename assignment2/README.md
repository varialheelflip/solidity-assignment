## 作业3：编写一个讨饭合约
### 合约地址
https://sepolia.etherscan.io/address/0xda5bd977398a72b83ea51f444d41efc1411b0d61
### 测试
#### donate执行成功
![](/.pic/捐赠测试.png)
#### donate event正常记录
![](/.pic/event记录.png)
#### 正常获取捐赠排名
![](/.pic/rank查询.png)
#### getDonation执行成功
![](/.pic/测试getDonation.png)
#### 测试设置捐赠时间限制, 不在捐赠时间范围donate失败
![](/.pic/设置时间.png)
![](/.pic/验证时间.png)
#### 非合约创建者withdraw失败
![](/.pic/非合约owner%20withdraw失败.png)
#### 合约创建者withdraw成功
![](/.pic/withdraw成功.png)