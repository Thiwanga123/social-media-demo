import ballerina/http;
import ballerina/time;

type User record {|
    readonly int id;
    string name;
    time:Date birthDate;
    string mobileNumber;
|};

type ErrorDetails record {
    string message;
    string details;
    time:Utc timestamp;
};


type UserNotFound record {|
    int status = http:STATUS_NOT_FOUND;
    ErrorDetails body;
|};

table <User> key(id) users = table[
    {id: 1, name: "Thiwanga", birthDate: {year: 1990, month: 1, day: 1}, mobileNumber: "1234567890"}
];
type NewUser record {
    string name;
    time:Date birthDate;
    string mobileNumber;
};

service /social\-media on new http:Listener(9090) {
    resource function get users() returns User[]|error {
        return users.toArray();
    }

    resource function get users/[int id]() returns User|UserNotFound|error {
        User? user = users[id];
        if user is () {
            UserNotFound userNotFound = {
                body: {
                    message: string `id: ${id}`,
                    details: string `user/${id}`,
                    timestamp: time:utcNow()}
            };
            return userNotFound;
        }
        return user;
    }


    resource function post users(NewUser newUser) returns http:Created|error {
       users.add({
           id: users.length() + 1,
           name: newUser.name,
           birthDate: newUser.birthDate,
           mobileNumber: newUser.mobileNumber
       });
       return http:CREATED;
    }

}