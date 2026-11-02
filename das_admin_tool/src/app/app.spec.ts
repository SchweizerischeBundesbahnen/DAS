import { CUSTOM_ELEMENTS_SCHEMA, signal } from '@angular/core';
import { TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { AuthService } from '~shared/services/auth.service';
import { environment } from '~src/environments/environment';
import { App } from './app';
import { Header } from './header/header';
import { IconSidebar } from './icon-sidebar/icon-sidebar';
import { setupInstana } from './instana-setup.util';

const mockAuthService: Partial<AuthService> = {
  isAuthenticated: signal(false),
};

describe('App', () => {
  let appended: HTMLScriptElement[];

  beforeEach(async () => {
    environment.instanaKey = 'test-key';
    appended = [];
    vi.spyOn(document.head, 'append').mockImplementation((...nodes) => {
      appended.push(...(nodes as HTMLScriptElement[]));
    });
    setupInstana();
    // Mock ineum function, as the injected Instana scripts never run
    // eslint-disable-next-line unicorn/no-global-object-property-assignment
    globalThis.ineum = vi.fn();

    await TestBed.configureTestingModule({
      imports: [App],
      providers: [provideRouter([]), { provide: AuthService, useValue: mockAuthService }],
    })
      .overrideComponent(App, {
        remove: { imports: [Header, IconSidebar] },
        add: { schemas: [CUSTOM_ELEMENTS_SCHEMA] },
      })
      .compileComponents();
  });

  afterEach(() => {
    environment.instanaKey = undefined;
    vi.restoreAllMocks();
  });

  const adBlockerNotification = (element: HTMLElement) => element.querySelector('sbb-notification');

  it('should create the app', () => {
    const fixture = TestBed.createComponent(App);
    const app = fixture.componentInstance;
    expect(app).toBeTruthy();
  });

  it('should not show the adblocker notification while the Instana script is still loading', async () => {
    const fixture = TestBed.createComponent(App);
    await fixture.whenStable();

    expect(adBlockerNotification(fixture.nativeElement as HTMLElement)).toBeNull();
  });

  it('should show the adblocker notification once the Instana script is blocked', async () => {
    const fixture = TestBed.createComponent(App);
    appended.find((script) => script.src.endsWith('eum.min.js'))!.dispatchEvent(new Event('error'));
    await fixture.whenStable();

    expect(adBlockerNotification(fixture.nativeElement as HTMLElement)).not.toBeNull();
  });
});
