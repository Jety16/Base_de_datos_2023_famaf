//Listar el nombre (name) y barrio (borough) de todos los restaurantes de cocina
//(cuisine) tipo "Italian" y que entre sus notas (grades) tengan al menos una
//entrada con nota (grade) "A" y puntaje (score) mayor o igual a 10. La lista final
//sólo deberá mostrar 1 entrada por restaurante y deberá estar ordenada de manera
//alfabética por el barrio primero y el nombre después. Hint: Revisar operadores
//$regex y $elemMatch.
db.restaurants.find(
    {
        cuisine: "Italian",
        grades: {
            $elemMatch: {
                grade: "A",
                score: { $gte: 10 }
            }
        }
    },
    {
        _id: 0,
        name: 1,
        borough: 1
    }
).sort({ borough: 1, name: 1 })

//Actualizar las panaderías (cuisine ~ Bakery) y las cafeterías (cuisine ~
//    Coffee) agregando un nuevo campo discounts que sea un objeto con dos campos:
//    day y amount. Si el local se ubica en Manhattan, el día será "Monday" y el
//    descuento será "%10". En caso contrario el día será "Tuesday" y el descuento será
//    "5%". Hint: Revisar el operador $cond.

db.restaurants.updateMany(
    {cuisine: { $in: ["Bakery", "Coffee"]},},
    {
        $set: {
            discounts:{
                $cond: {
                    if: { $eq: ["$borough", "Manhattan"]},
                    then: {day: "Monday", amount: "%10"},
                    else: {day: "Tuesday", amount: "%5"},
                }
            }
        }
    }    
)

//Contar la cantidad de restaurantes cuyo address.zipcode se encuentre entre
//10000 y 11000. Tener en cuenta que el valor original es un string y deberá ser
//convertido. También tener en cuenta que hay casos erróneos que no pueden ser
//convertidos a número, en cuyo caso el valor será reemplazado por 0. Hint: Revisar
//el operador $convert.

//Version con agreggate
db.restaurants.aggregate([
    {
        $addFields: {
            zipcodeNumber: {
                $convert: {
                    input: "$address.zipcode",
                    to: "int",
                    onError: 0
                }
            }
        }
    },
    {
        $match: {
            zipcodeNumber: { $gte: 10000, $lte: 11000 }
        }
    },
    {
        $count: "count"
    }
])

//Version sin agreggate
db.restaurants.find({
    $where: function() {
        var zipcode = Number(this.address.zipcode);
        if (isNaN(zipcode)) {
            zipcode = 0;
        }
        return zipcode >= 10000 && zipcode <= 11000;
    }
}).count()

//Por cada tipo de cocina (cuisine), contar la cantidad de notas distintas recibidas
//(grades.grade) en el segundo semestre de 2013. Ordenar por tipo de cocina y nota.

db.restaurants.aggregate([
    {
        $unwind: "$grades" // Descomponemos el array de grades
    },
    {
        $match: { // Filtramos por fecha
            "grades.date": {
                $gte: ISODate("2013-07-01"),
                $lte: ISODate("2013-12-31")
            }
        }
    },
    {
        $group: { //Agrupamos por tipo de cocina y nota
            _id: {
                cuisine: "$cuisine", 
                grade: "$grades.grade"
            }
        }
    },
    {
        $group: { //Agrupamos por tipo de cocina y contamos
            _id: "$_id.cuisine", 
            count: { $sum: 1 }
        }
    },
    {
        $sort: {
            _id: 1
        }
    }
])

//Data la siguiente tabla de conversión de notas (grades.grade):
//A 5
//B 4
//C 3
//D 2
//* 1
//Donde "*" sería el resto de los casos posibles. Transformar las notas de los
//restaurantes de acuerdo a la tabla. Luego, calcular la nota promedio, máxima y
//mínima por tipo de cocina (cuisine). El resultado final deberá mostrar la cocina, la
//nota promedio, la nota máxima y la nota mínima, ordenadas de manera descendente
//por la nota promedio. Hint: Revisar el operador $switch.

db.restaurants.aggregate([
    {
        $unwind: "$grades" // Descomponemos el array de grades
    },
    {
        $addFields: { // Agregamos el campo gradeNumber
            gradeNumber: { // Transformamos la nota
                $switch: { // Switch para transformar la nota
                    branches: [ // Branches para cada caso
                        { case: { $eq: ["$grades.grade", "A"] }, then: 5 },
                        { case: { $eq: ["$grades.grade", "B"] }, then: 4 },
                        { case: { $eq: ["$grades.grade", "C"] }, then: 3 },
                        { case: { $eq: ["$grades.grade", "D"] }, then: 2 },
                    ],
                    default: 1
                }
            }
        }
    },
    {
        $group: { // Agrupamos por tipo de cocina
            _id: {
                cuisine: "$cuisine"
            },
            average: { $avg: "$gradeNumber" }, // Calculamos promedio, maximo y minimo
            max: { $max: "$gradeNumber" },
            min: { $min: "$gradeNumber" }
        }
    },
    {
        $sort: {
            average: -1
        }
    }
])

//Especificar reglas de validación para la colección restaurant utilizando JSON
// Schema. Tener en cuenta los campos: address (con sus campos anidados),
// borough, cuisine, grades (con sus campos anidados), name, restaurant_id, y
// discount (con sus campos anidados). Inferir tipos y otras restricciones que considere
// adecuadas (incluyendo campos requeridos). Agregar una regla de validación para
// que el zipcode, aún siendo un string, verifique que el rango esté dentro de lo
// permitido para New York City (i.e. 10001-11697). Finalmente dejar 2 casos de falla
// ante el esquema de validación y 1 caso de éxito. Hint: Deberán hacer conversión
// con $convert en el caso de la regla de validación. Los casos no deben ser triviales
// (i.e. sólo casos de falla por un error de tipos).

db.runCommand({
    collMod: "restaurants",
    validator: {
        $jsonSchema:{
            bsonType: "object",
            required: ["address", "borough", "cuisine", "grades", "name", "restaurant_id", "discount"],
            properties: {
                address: {
                    bsonType: "object",
                    required: ["building", "coord", "street", "zipcode"],
                    properties: {
                        building: {bsonType: "string"},
                        coord: {
                            bsonType: "array",
                            items: {bsonType: "double"}
                        },
                        street: {bsonType: "string"},
                        zipcode: {
                            bsonType: "string",
                            pattern: "^(100[0-9][0-9]|10[1-9][0-9][0-9]|11[0-6][0-9][0-9]|11697)$"
                        }
                    }
                },
                borough: {bsonType: "string"},
                cuisine: {bsonType: "string"},
                grades: {
                    bsonType: "array",
                    items: {
                        bsonType: "object",
                        required: ["date", "grade", "score"],
                        properties: {
                            date: {bsonType: "date"},
                            grade: {bsonType: "string"},
                            score: {bsonType: "int" }
                        }
                    }
                },
                name: {bsonType: "string"},
                restaurant_id: {bsonType: "string"},
                discount: {
                    bsonType: "object",
                    required: ["day", "amount"],
                    properties: {
                        day: {bsonType: "string"},
                        amount: {bsonType: "string"}
                    }
                }
            }
        }
    }
})

//Caso exito 
db.restaurants.insertOne({
    address: {
        building: "123",
        coord: [-73.856077, 40.848447],
        street: "Main Street",
        zipcode: "10001"
    },
    borough: "Manhattan",
    cuisine: "Italian",
    grades: [
        {
            date: new Date(),
            grade: "A",
            score: 10
        }
    ],
    name: "Test Restaurant",
    restaurant_id: "12345678",
    discount: {
        day: "Monday",
        amount: "10%"
    }
})

//Caso falla 1
db.restaurants.insertOne({
    address: {
        building: "123",
        coord: [-73.856077, 40.848447],
        street: "Main Street",
        zipcode: "99999"
    },
    borough: "Manhattan",
    cuisine: "Italian",
    grades: [
        {
            date: new Date(),
            grade: "A",
            score: 10
        }
    ],
    name: "Test Restaurant",
    restaurant_id: "12345678",
    discount: {
        day: "Monday",
        amount: "10%"
    }
})

//Caso falla 2
db.restaurants.insertOne({
    address: {
        building: "123",
        coord: [-73.856077, 40.848447],
        street: "Main Street",
        zipcode: "abcde"
    },
    borough: "Manhattan",
    cuisine: "Italian",
    grades: [
        {
            date: new Date(),
            grade: "A",
            score: 10
        }
    ],
    name: "Test Restaurant",
    restaurant_id: "12345678",
    discount: {
        day: "Monday",
        amount: "10%"
    }
})

/*
Se desean agregar "client reviews", dados por los clientes de los restaurantes. Los
reviews cuentan de un título de menos de 50 caracteres, un puntaje entero entre 0 y
5, una reseña de máximo 250 caracteres (que es opcional) y una fecha y un cliente
que lo realizó (con información de nombre y correo electrónico del cliente). Cada
review está asociado a un restaurante y un mismo restaurante puede tener varios
reviews. Asimismo, un cliente puede hacer reviews de varios restaurantes distintos.
Teniendo en cuenta esto, decida la mejor manera de agregar esta información a la
base de datos (y justifique su decisión en un comentario), genere un esquema de
validación para dicha información y agregue algunos documentos de ejemplo. */

db.createCollection(
    "reviews",
    {
        validator: {
            $jsonSchema: {
                bsonType: "object",
                required: ["title", "score", "date", "client", "restaurant"],
                properties: {
                    title: {
                        bsonType: "string",
                        maxLength: 50
                    },
                    score: {
                        bsonType: "int",
                        minimum: 0,
                        maximum: 5
                    },
                    review: {
                        bsonType: "string",
                        maxLength: 250
                    },
                    date: {bsonType: "date"},
                    client: {
                        bsonType: "object",
                        required: ["name", "email"],
                        properties: {
                            name: {bsonType: "string"},
                            email: {bsonType: "string"}
                        }
                    },
                    restaurant: {bsonType: "objectId"}
                }
            }
        }
    }
)

//Caso exito
db.reviews.insertOne({
    title: "Great!",
    score: 5,
    review: "Great food, great service",
    date: new Date(),
    client: {
        name: "John Doe",
        email: "JohnDoe@gmail.com",
    },
    restaurant: ObjectId("65572467d1829d573dcdecfd")
})

//Caso exito 2
db.reviews.insertOne({
    title: "Bad!",
    score: 0,
    date: new Date(),
    client: {
        name: "John Doe",
        email: "JohnDoe@gmail.com",
    },
    restaurant: ObjectId("65572467d1829d573dcdecfd")
})

