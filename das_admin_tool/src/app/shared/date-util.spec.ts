import {toUtcDateOnly} from './date-util';

describe('toUtcDateOnly', () => {
  it('should convert a date with to date', () => {
    const input = new Date('2026-03-21T05:00:00+01:00');

    const result = toUtcDateOnly(input);

    expect(result.getTime()).toBe(
      Date.UTC(2026, 2, 21)
    );
  });

});
