'use strict';
//
// HANDLE / ASSERT
//
/* eslint-disable prefer-rest-params */
module.exports = function HandlorExtension(Cannot) {
  function assertIs(err, verb, object) {
    if (typeof object === 'string'
    && Cannot.codify(verb) === err.verb
    && Cannot.codify(object) === err.object) {
      return true;
    }
    return false;
  }

  function assertBecause(errReason, checkReason) {
    return typeof checkReason === 'string' && errReason === Cannot.codify(checkReason);
  }

  function handlor(verb, object) {
    const reason = arguments.length > 3 ? arguments[2] : null;
    const fn = arguments.length > 3 ? arguments[3] : arguments[2];

    const isCannot = assertIs(this, verb, object);
    const isReason = reason ? assertBecause(this.reason, reason) : true;

    if (isCannot && isReason && fn) {
      return fn.call(this, this.reason, this);
    }
    const ctx = this;
    const withInterface = {
      with: (reasonArg, fnArg) => {
        const withReason = typeof reasonArg === 'function' ? null : reasonArg;
        const withFn = typeof reasonArg === 'function' ? reasonArg : fnArg;
        if ((withReason && assertBecause(ctx.reason, withReason))
        || !withReason) {
          const handled = !!withFn.call(ctx, ctx.reason, ctx);
          if (handled) {
            withInterface.with = () => withInterface;
          }
        }
        return withInterface;
      },
    };

    return withInterface;
  }

  Cannot.extend('handle', handlor);
  Cannot.extend('handlor', handlor);
};