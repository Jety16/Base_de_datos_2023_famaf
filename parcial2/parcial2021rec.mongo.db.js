/* Listar el id, nombre, apellido, y "works_on" de los empleados que hayan trabajado
más de 25 horas en algunos de los proyectos con id igual a 1 o 3.*/
db.employee.find({
    works_on : {
        $elemMatch: {
            hours : {$gte: 25},
            $or:[
                {proj_number:1},
                {proj_number:3}
            ]}
        }
    },
    {
        _id:1, name:1, works_on:1
    }
)

//Calcular el salario promedio por puesto de empleo (title). Listar en orden alfabético.
db.employee.aggregate([
    {
        $group: {
            _id: "$title",
            avgSalary: { $avg: "$salary" }
        }
    },
    {
        $sort: { _id: 1 }
    }
])




//Listar el nombre de los gerentes que están a cargo de los departamentos ubicados en Houston. Listar en orden alfabético.
db.department.aggregate([
    {
        $match: {
            locations: { $in: ["Houston"] }
        }
    },
    {
        $lookup: {
            from: "employee",
            localField: "manager_emp_id",
            foreignField: "_id",
            as: "manager"
        }
    },
    {
        $project: {
            _id: 0,
            manager: 1
        }
    }
]).sort({"manager.name":1})


//Listar cantidad de departamentos por ubicación (location). Ordenar por cantidad y mostrar solo los dos primeros documentos.
db.department.aggregate([
    {
        $unwind: "$locations" //Separamos el array de locations en documentos distintos
    },
    {
        $group: { //Agrupamos por location y contamos
            _id: "$locations",
            count: { $sum: 1 }
        }
    },
    {
        $sort: { count: -1 }
    },
    {
        $limit: 2
    }
])

/*
Crear una vista con información de nombre, apellido, y salario de los empleados en
el departamento 'Research' que ganan entre $27000 y $37000. Listar en orden
alfabético.
*/

db.createView(
    "researchEmployees", 
    "employee", [
        {
            $match: {
                department: "Research",
                salary: { $gte: 27000, $lte: 37000 }
            }
        },
        {
            $project: {
                _id: 0,
                name: 1,
                lastname: 1,
                salary: 1
            }
        },
        {
            $sort: { name: 1 }
        }
    ])

/*
Especificar reglas de validación usando JSON Schema en la colección “employee” a
los siguientes campos: name, salary, y title. Inferir los tipos y otras restricciones que
considere adecuados para especificar las reglas a partir de los documentos de la
colección. Testear la regla de validación generando dos casos de falla en la regla de
validación y dos casos donde cumple la regla de validación.
*/

db.runCommand({
    collMod: "employee",
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["name", "salary", "title"],
            properties: {
                name: {
                    bsonType: "string",
                    description: "must be a string and is required"
                },
                salary: {
                    bsonType: "int",
                    description: "must be a int and is required"
                },
                title: {
                    bsonType: "string",
                    description: "must be a string and is required"
                }
            }
        }
    }
})

//Casos de falla
db.employee.insertOne({
    name: "Juan",
    salary: "1000",
    title: "Developer"
})

db.employee.insertOne({
    name: "Juan",
    salary: 1000,
    title: 123
})

//Casos de exito
db.employee.insertOne({
    name: "Juan",
    salary: 1000,
    title: "Developer"
})
