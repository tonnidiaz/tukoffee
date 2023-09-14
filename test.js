let obj = {name: "Johny", age: 10}

let ks = Object.keys(obj)
console.log(typeof ks)
for (let k of ks){
    console.log(k, obj[k])
}