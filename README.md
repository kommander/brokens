cannot.js
=========

Easy and fun error handling, by enforcing human readable messages without compromising machine processing ability.
  
[![Build Status](https://travis-ci.org/kommander/cannot.js.png)](https://travis-ci.org/kommander/cannot.js)  
  
## Example

```javascript  
var err = Alice.cannot('attend', 'the party').because('she fell into a rabbit hole');  
// err.message       -> {String} "Alice could not attend the party, because she fell into a rabbit hole."  
// err.object        -> {String} "Alice"  
// err.code          -> {String} "cannot_attend_the_party"  
// err.action        -> {String} "attend"  
// err.subject       -> {String} "the_party"  
// err.reason        -> {String} "she_fell_into_a_rabbit_hole"
// err.context       -> {Object} Alice
```

So how is that applicable to a real world programming example?  

```javascript
var db = new Database();

var err = db.cannot('load', 'User').because('connection was lost');
// err.message       -> {String} "Database could not load User, because connection was lost."  
// err.object        -> {String} "Database"  
// err.code          -> {String} "cannot_load_user"  
// err.action        -> {String} "load"  
// err.subject       -> {String} "user"  
// err.reason        -> {String} "connection_was_lost"
// err.context       -> {Object} db
```

## Installation  

	$ npm install cannot

## Introduction
`Cannot.js` follows a very simple syntax. It makes you think about what really went wrong and helps you to avoid inconsistent error codes. 

`Object` cannot `perform action` on `subject`, because `it had a reason`.

The generated message aims to be as user friendly as possible, without you having to write it manually. All error specific data which you need to handle it elsewhere in your application, is derived from your simple specification.  
The `because` api helps you to specify a reason, which allows you to pass on error objects as well.

## Inform  
With `cannot.js` an object and even its constructor can `inform` you whenever it `cannot` perform and action.
You can listen on any object with the `Object#inform` method for failures.

### Be informed by an object instance

```javascript  
var db = new Database();

db.inform(function(err){
  // err -> "Database cannot load User because connection was lost"
});

db.cannot('load', 'User').because('connection was lost');
```

### Be informed by an object constructor
```javascript  
Database.inform(function(err, instance){
  // err.context -> {Object} db1
  // err.context -> {Object} db2
});

var db1 = new Database();
var db2 = new Database();

db1.cannot('load', 'User');
db2.cannot('load', 'User');
```

### Emit an 'error' event 
With a `createHook` we can extend the behaviour of the error handling. By specifying the following hook we can emit an "error" event directly on the object, if it is an EventEmitter.

```javascript
Cannot.createHook(function(){
  // Emit error event
  if(this.context && this.context instanceof EventEmitter){
    this.context.emit('error', this);
  }
});
```

Now we can use existing error listeners or classic event handling for errors:

```javascript  
function Database(…){
  // …
}
Database.prototype.__proto__ = EventEmitter.prototype;

var db = new Database();

db.on("error", function(err){
  // err -> "Database cannot load User. (No reason)"
});

db.cannot('load', 'User');
```

This _default behaviour_ can be deactivated by changing the global setting `Cannot.emitErrorEvent` to `false`.

### Listen for specific action/subject combinations
The `inform` method allows you to listen for a specific action only and even more: a specific subject.  
  
So lets say you want to handle an error from your database instance whenever a "save" action fails, but you want to handle "load" errors separately:

```javascript  
db.inform("save", function(err){
  // err -> "Database could not save User. (No reason)"
  // Will _not_ receive the second error with the "load" action
});

db.cannot('save', 'User');
db.cannot('load', 'User');
```

To only listen for a specific action/subject combination, add the subject of interest as second argument. Internally, the action and subject descriptions are codified and therefor case insensitive.

```javascript  
db.inform("save", "user", function(err){
  // err -> "Database could not save User. (No reason)"
  // Will _not_ receive the second error with the "Profile" subject
});

db.cannot('save', 'User');
db.cannot('save', 'Profile');
```

## Stacking Errors
// TODO

## Reasons
// TODO

## Creating Errors
An exception can be created from calling `Cannot()` as a function, or by calling `Object#cannot()`, which both will return a `Cannot` instance. A `Cannot` instance can also be `thrown`.  
When using `Cannot()` standalone with default configuration, it tries to grab the object which `could not` perform an action from the stack trace.
Using the `Object#cannot` API extension though obviously has an object which `could not`.

## Running the tests
	
	$ make test  

Will run `npm install` to make sure dev dependencies are installed and then run the tests using [mocha](http://visionmedia.github.io/mocha/).

## License

(The MIT License)

Copyright (c) 2013 Sebastian Herrlinger (https://github.com/kommander)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.