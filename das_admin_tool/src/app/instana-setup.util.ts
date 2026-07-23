import { environment } from '~src/environments/environment';

export const setupInstana = (): void => {
  const instanaKey = environment.instanaKey;
  // Add ineum as noop to not have runtime errors
  if (!instanaKey) {
    // eslint-disable-next-line unicorn/no-global-object-property-assignment
    globalThis.ineum = function () {
      return '';
    };
    return;
  }

  // Create a script element with the instana key that will be injected to head
  const script = document.createElement('script');
  script.innerHTML = String.raw`
      (function (s, t, a, n) {
        s[t] ||
          ((s[t] = a),
          (n = s[a] =
            function () {
              n.q.push(arguments);
            }),
          (n.q = []),
          (n.v = 2),
          (n.l = 1 * new Date()));
      })(window, 'InstanaEumObject', 'ineum');

      ineum('reportingUrl', 'https://eum-green-saas.instana.io');
      ineum('key', '${instanaKey}');
      ineum('trackSessions');
      ineum('allowedOrigins', [/.*\.api\.sbb\.ch/i]);
    `;

  const scriptCode = document.createElement('script');
  scriptCode.defer = true;
  scriptCode.crossOrigin = 'anonymous';
  scriptCode.src = 'https://eum.instana.io/1.8.1/eum.min.js';
  scriptCode.integrity = 'sha384-qFzHZ5BC7HOPEBSYkbYSv+DBWrG34P1QW9mIaCR41db6yOJNYmH4antW6KLkc6v1';

  document.head.append(scriptCode);
  document.head.append(script);
};
