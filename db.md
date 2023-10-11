# Database

## Product
- name: Sting
- id: int
- quantity: int
- description: String
- ratings: [double] 
- price: double 

## Customer
- firstName: string
- lastName: string
- email: string
- phone: string
- address: Address
- cart: Cart
- orders: [Order]

## Stuff: Customer
- role: string
- permissions: [read/write/delete]


## Order
- id: int
- customer: Customer
- products: [Product]
- status: OrderStatus
- billingAddress: Address
- deliveryAddress: Address
- dateCreated: date
- dateDelivered: date
- lastModified: date

## Cart
- customer: Customer
- products: [Product]

## OrderStatus
- pending
- delivered
- canceled

## Address
- street: string
- province: string
- town: string
- phone: string?