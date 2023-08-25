console.log("Main.js")
const queryString = window.location.search;
const params = new URLSearchParams(queryString);
console.log(params.get("token"))
async function createOrder (data, actions){
    console.log("creating order")
    return actions.order.create({
        purchase_units: [
            {
              amount: {
                value: `5`,
                currency_code: "USD",
              },
            },
          ],
    }).then(orderId=> orderId)
    .catch(e=>{
        console.log(e);
    });`12qaz`
}
paypal_sdk.Buttons({
        createOrder
    }).render("#paypal");

 