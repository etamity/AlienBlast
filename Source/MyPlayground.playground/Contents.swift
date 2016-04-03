//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"


func checkLevelUpgrade(exp:Int)->Int{
    let constA :Double = 8.7
    let constB :Double = -40.0
    let constC :Double = 111.0
    let level : Double = max(floor( constA * log(Double(exp) + constC) + constB ), 1 )
    
    return Int(level)
}
var oldLevel = 0;
for i in 0 ..< 1000{
    var level = checkLevelUpgrade(i)
    if (oldLevel < level)
    {
        oldLevel = level
        print("Level:",oldLevel , "   ",i );
    }
}

var level = checkLevelUpgrade(10000000)
