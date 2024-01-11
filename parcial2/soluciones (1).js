// NO DARLE BOLA A ESTO, ES PARA PODER GUIARME NOMAS  AL RESOLVER LOS EJER.
//sales table
// {
//  _id: ObjectId("5bd761dcae323e45a93ccfe8"),
//  saleDate: ISODate("2015-03-23T21:06:49.506Z"),
//  items: [
//    {
//      name: 'printer paper',
//      tags: [ 'office', 'stationary' ],
//      price: Decimal128("40.01"),
//      quantity: 2
//    },
//    {
//      name: 'notepad',
//      tags: [ 'office', 'writing', 'school' ],
//      price: Decimal128("35.29"),
//      quantity: 2
//    },
//    {
//      name: 'pens',
//      tags: [ 'writing', 'office', 'school', 'stationary' ],
//      price: Decimal128("56.12"),
//      quantity: 5
//    },
//    {
//      name: 'backpack',
//      tags: [ 'school', 'travel', 'kids' ],
//      price: Decimal128("77.71"),
//      quantity: 2
//    },
//    {
//      name: 'notepad',
//      tags: [ 'office', 'writing', 'school' ],
//      price: Decimal128("18.47"),
//      quantity: 2
//    },
//    {
//      name: 'envelopes',
//      tags: [ 'stationary', 'office', 'general' ],
//      price: Decimal128("19.95"),
//      quantity: 8
//    },
//    {
//      name: 'envelopes',
//      tags: [ 'stationary', 'office', 'general' ],
//      price: Decimal128("8.08"),
//      quantity: 3
//    },
//    {
//      name: 'binder',
//      tags: [ 'school', 'general', 'organization' ],
//      price: Decimal128("14.16"),
//      quantity: 3
//    }
//  ],
//  storeLocation: 'Denver',
//  customer: { gender: 'M', age: 42, email: 'cauho@witwuta.sv', satisfaction: 4 },
//  couponUsed: true,
//  purchaseMethod: 'Online'
//}
//
//storeObjetives table
//{ _id: 'London', objective: 324 }
// sales: Cada documento de la colección sales representa una única venta de una tienda administrada por la empresa de suministro. 
//Cada documento contiene los artículos (items) comprados, información sobre el cliente que realizó la compra y otros detalles relacionados con la venta.
// storeObjectives: Cada documento de esta colección tiene dos valores: 
// Como id el “storeLocation” de una tienda, y un valor llamado “objective” qué es el objetivo de venta totales de la tienda en cuestión.

/////////////////////////////////////////
////////////////////////////////////////
////////////////////////////////////////
///////////////////////////////////////
///////////////////////////////////////
////////////////////////////////////////
///////////////////////////////////////


// Resoloución

// 1 Buscar las ventas realizadas en "London", "Austin" o "San Diego"; a un customer con edad mayor-igual a 18 años que tengan productos que hayan salido al menos 1000 y estén etiquetados (tags) como de tipo "school" o "kids" (pueden tener más etiquetas).
//  Mostrar el id de la venta con el nombre "sale", la fecha (“saleDate"), el storeLocation, y el "email del cliente. No mostrar resultados anidados. 
db.sales.aggregate([
    {
        $match: {
            storeLocation: { $in: ["London", "Austin", "San Diego"] },
            "customer.age": { $gte: 18 },
            items: {
                $elemMatch: {
                    price: { $gte: 1000 },
                    tags: { $in: ["school", "kids"] }
                }
            }
        }
    },
    {
        $project: {
            sale: "$_id",
            saleDate: 1,
            storeLocation: 1,
            email: "$customer.email",
            _id: 0
        }
    }
])

// 2 Buscar las ventas de las tiendas localizadas en Seattle, donde el método de compra sea ‘In store’ o ‘Phone’ y se hayan realizado entre 1 de febrero de 2014 y
//   31 de enero de 2015 (ambas fechas inclusive). 
//   Listar el email y la satisfacción del cliente, y el monto total facturado, donde el monto de cada item se calcula como 'price * quantity'.
//   Mostrar el resultado ordenados por satisfacción (descendente), frente a empate de satisfacción ordenar por email (alfabético). 


db.sales.aggregate([
    {
        $match: {
            storeLocation: "Seattle",
            purchaseMethod: { $in: ["In store", "Phone"] },
            saleDate: {
                $gte: new Date("2014-02-01"),
                $lte: new Date("2015-01-31")

            }
        }
    },
    {
        $addFields: {
            totalAmount: {
                $sum: {
                    $map: {
                        input: "$items",
                        as: "item",
                        in: { $multiply: ["$$item.price", "$$item.quantity"] }
                    }
                }
            }
        }
    },
    {
        $sort: { "customer.satisfaction": -1, "customer.email": 1 }
    },
    {
        $project: {
            _id: 0,
            email: "$customer.email",
            satisfaction: "$customer.satisfaction",
            totalAmount: 1
        }
    }
])

// 3  Crear la vista salesInvoiced que calcula el monto mínimo, monto máximo, monto total y monto promedio facturado por año y mes. 
//    Mostrar el resultado en orden cronológico. No se debe mostrar campos anidados en el resultado.

db.createView(
    "salesInvoiced",
    "sales",
    [
        {
            $addFields: {
                totalAmount: {
                    $sum: {
                        $map: {
                            input: "$items",
                            as: "item",
                            in: { $multiply: ["$$item.price", "$$item.quantity"] }
                        }
                    }
                },
                year: { $year: "$saleDate" },
                month: { $month: "$saleDate" }
            }
        },
        {
            $group: {
                _id: { year: "$year", month: "$month" },
                minAmount: { $min: "$totalAmount" },
                maxAmount: { $max: "$totalAmount" },
                totalAmount: { $sum: "$totalAmount" },
                avgAmount: { $avg: "$totalAmount" }
            }
        },
        {
            $sort: { "_id.year": 1, "_id.month": 1 }
        },
        {
            $project: {
                _id: 0,
                year: "$_id.year",
                month: "$_id.month",
                minAmount: 1,
                maxAmount: 1,
                totalAmount: 1,
                avgAmount: 1
            }
        }
    ]
)


//  4 Mostrar el storeLocation, la venta promedio de ese local, 
//    el objetivo a cumplir de ventas (dentro de la colección storeObjectives) y 
//    la diferencia entre el promedio y el objetivo de todos los locales.
db.sales.aggregate([
    {
        $unwind: "$items"
    },
    {
        $group: {
            _id: "$storeLocation",
            avgSale: { $avg: { $multiply: ["$items.price", "$items.quantity"] } }
        }
    },
    {
        $lookup: {
            from: "storeObjectives",
            localField: "_id",
            foreignField: "_id",
            as: "storeObjective"
        }
    },
    {
        $unwind: "$storeObjective"
    },
    {
        $addFields: {
            objective: "$storeObjective.objective",
            difference: { $subtract: ["$storeObjective.objective", "$avgSale" ] }
        }
    },
    {
        $project: {
            _id: 0,
            storeLocation: "$_id",
            avgSale: 1,
            objective: 1,
            difference: 1
        }
    }
])


// 5 Especificar reglas de validación en la colección sales utilizando JSON Schema. 
//   Las reglas se deben aplicar sobre los campos: saleDate, storeLocation, purchaseMethod, y  customer 
//   ( y todos sus campos anidados ). Inferir los tipos y otras restricciones que considere adecuados para
//   especificar las reglas a partir de los documentos de la colección. 
//   Para testear las reglas de validación crear un caso de falla en la regla de validación y un caso de éxito (Indicar si es caso de falla o éxito)
db.runCommand({
    collMod: "sales",
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: [ "storeLocation", "purchaseMethod", "saleDate", "customer"],
            properties: {
                saleDate: {
                    bsonType: "date",
                    description: "must be a date and is required"
                },
                storeLocation: {
                    bsonType: "string",
                    description: "must be a string and is required"
                },
                purchaseMethod: {
                    bsonType: "string",
                    description: "must be a string and is required"
                },
                customer: {
                    bsonType: "object",
                    required: ["name", "age", "email"],
                    properties: {
                        name: {
                            bsonType: "string",
                            description: "must be a string and is required"
                        },
                        age: {
                            bsonType: "int",
                            minimum: 0,
                            description: "must be an integer and is required"
                        },
                        email: {
                            bsonType: "string",
                            description: "must be a string and is required"
                        }
                    }
                }
            }
        }
    }
})



// Caso de falla
db.sales.insert({
    saleDate: "2022-01-01", // Esto va a fallar porque saleDate debe ser un objeto Date, no una string,,, 
    storeLocation: "London",
    purchaseMethod: "Online",
    customer: {
        name: "pepe",
        age: 30,
        email: "pepe@example.com"
    }
})

// Caso de exito, anda todo bien
db.sales.insert({
    saleDate: new Date(),
    storeLocation: "London",
    purchaseMethod: "Online",
    customer: {
        name: "epep",
        age: 30,
        email: "moc.elpmaxe@epep"
    }
})