export function randomIntFromInterval(min: number, max: number) {
    // min and max included
    return Math.floor(Math.random() * (max - min + 1) + min);
  }
export const randomImg = ()=>{
    return `https://loremflickr.com/g/320/240/tech?random=${randomIntFromInterval(1, 100)}`
}
