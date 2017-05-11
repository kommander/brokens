Brokens
=========
_A broken-promise resolver._

Aiding in creating consistently human readable messages without compromising machine processing ability. A _Broken_ extends the base _Error_, can be thrown and behaves just like expected. With a sweet syntax.

[![Build Status](https://travis-ci.org/kommander/brokens.png)](https://travis-ci.org/kommander/brokens) [![Coverage Status](https://coveralls.io/repos/github/kommander/brokens/badge.svg?branch=master)](https://coveralls.io/github/kommander/brokens?branch=master)

**Install**   
```
$ npm install brokens
```

**Core**  
An error can be expressed by calling `cannot(verb, object)` as a function which will return a `Broken` instance. A `Broken` instance can also be `thrown` like a generic `Error`.
```js
const cannot = require('brokens');
throw cannot('attend', 'the party').because('I fell into a rabbit hole');  
// err.message   -> {String} "I could not attend the party, because I fell into a rabbit hole."  
// err.code      -> {String} "cannot_attend_the_party"  
// err.reason    -> {String} "i_fell_into_a_rabbit_hole"
```

## Semantics
`Brokens` follow a very simple syntax.

```js
// Tell me what the problem is...
throw I.cannot('do', 'my work')
  .because(TheDatabase.cannot('find', 'what I was looking for')
    .because('something is broken'));
```

`Subject` cannot `perform verb/action` on `object/data`, because `it had a reason`.

The generated message aims to be as user friendly as possible, without spoiling risky information. All error specific data which you need to handle it elsewhere in your application, is derived from your simple declaration.  
The `because` api helps you to specify a reason, which allows you to stack error instances like a `Broken` as well.

#### Stacking Errors
`Broken` instances can be stacked onto each other by handing them over as a reason to the next error.

```javascript
var err1 = cannot('do', 'what I should do');
var err2 = cannot('do', 'what I should do').because(err1);
var err3 = cannot('do', 'what I should do').because(err2);

console.log(err3.message);
```

This should produce the following output:  
```
I could not do what I should do
    because I could not do what I should do
    because I could not do what I should do. (No reason)
```

For more information on stacking errors, have a look at the [examples](https://github.com/kommander/cannot.js/tree/master/examples)

## Recovery
`Brokens` should be handled and never ever be silently dropped. Most errors can be recovered from, which makes the overall user experience better and the application more stable as it becomes self sufficient. This approach supports a _Self Healing Architecture_, in which the application can _reason_ about what happened and choose a recovery strategy accordingly or provide the users with recovery options.

# Contribute
## Develop
To start developing, check out this repository and do:

```
$ make dev
```

Installs the initial dev dependencies, sets up git hooks and checks linting to be able run mincov before you push. Happy hacking!

## Make
For all make targets see:
```
$ make help
```

## Tests
It is unavoidable to run into issues, but a _100%_ test coverage helps making sure the demons don't return.
[Mocha](http://mochajs.org) is the test runner in use,
extended by [expect.js](https://github.com/Automattic/expect.js) and [should](https://shouldjs.github.io) within a [BDD](https://en.wikipedia.org/wiki/Behavior-driven_development) setup.
```
$ make test
```

## Specs
To add a feature to development, write a test to add to the spec in a feature branch.
```
$ make specs
```

Creates the specs file. `cat specs`.

## Coverage

To generate a test coverage report, it uses [istanbul](https://gotwarlost.github.io/istanbul/).
```
$ make coverage
```

## License

(The MIT License)

Copyright (c) 2017 Sebastian Herrlinger (https://github.com/kommander)

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
