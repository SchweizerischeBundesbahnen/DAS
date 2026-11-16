import { environment } from '~src/environments/environment';
import { isInstanaBlocked, setupInstana } from './instana-setup.util';

describe('setupInstana', () => {
  let appended: HTMLScriptElement[];

  beforeEach(() => {
    environment.instanaKey = 'test-key';
    appended = [];
    vi.spyOn(document.head, 'append').mockImplementation((...nodes) => {
      appended.push(...(nodes as HTMLScriptElement[]));
    });
  });

  afterEach(() => {
    environment.instanaKey = undefined;
    vi.restoreAllMocks();
  });

  const eumScript = () => appended.find((script) => script.src.endsWith('eum.min.js'))!;

  it('should not report Instana as blocked while the script is loading', () => {
    setupInstana();

    expect(isInstanaBlocked()).toBe(false);
  });

  it('should report Instana as blocked when the script fails to load', () => {
    setupInstana();
    eumScript().dispatchEvent(new Event('error'));

    expect(isInstanaBlocked()).toBe(true);
  });

  it('should not report Instana as blocked when the script loads', () => {
    setupInstana();
    eumScript().dispatchEvent(new Event('load'));

    expect(isInstanaBlocked()).toBe(false);
  });
});
