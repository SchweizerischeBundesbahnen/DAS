import { ComponentFixture, TestBed } from '@angular/core/testing';
import { AppVersionDialog, normalizeVersion } from './app-version-dialog';

describe('AppVersionDialog', () => {
  let component: AppVersionDialog;
  let fixture: ComponentFixture<AppVersionDialog>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AppVersionDialog],
    }).compileComponents();

    fixture = TestBed.createComponent(AppVersionDialog);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  function setVersion(version: string): void {
    component['appVersionModel'].update((value) => ({ ...value, version }));
  }

  function isVersionValid(): boolean {
    return component['appVersionForm'].version().valid();
  }

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should accept versions up to 99999 per part', () => {
    setVersion('99999.99999.99999');

    expect(isVersionValid()).toBe(true);
  });

  it.each(['100000.0.0', '1.2', '1.2.3.400', 'a.b.c'])(
    'should reject invalid version %s',
    (version) => {
      setVersion(version);

      expect(isVersionValid()).toBe(false);
    },
  );

  it('should accept and normalize leading zeros and whitespace', () => {
    setVersion(' 01.02.003 ');

    expect(isVersionValid()).toBe(true);
    expect(component.formValue.version).toBe('1.2.3');
  });

  it('should reject a version that exceeds 99999 after normalization', () => {
    setVersion('0100000.0.0');

    expect(isVersionValid()).toBe(false);
  });
});

describe('normalizeVersion', () => {
  it('should keep zero parts', () => {
    expect(normalizeVersion('0.0.0')).toBe('0.0.0');
  });

  it('should strip leading zeros of each part', () => {
    expect(normalizeVersion('00.010.0007')).toBe('0.10.7');
  });
});
