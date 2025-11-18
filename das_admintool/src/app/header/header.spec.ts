import {ComponentFixture, TestBed} from '@angular/core/testing';
import packageJson from '../../../package.json';

import {Header} from './header';

describe('Header', () => {
  let component: Header;
  let fixture: ComponentFixture<Header>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Header]
    })
      .compileComponents();

    fixture = TestBed.createComponent(Header);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should render title and version', () => {
    const fixture = TestBed.createComponent(Header);
    fixture.detectChanges();
    const compiled = fixture.nativeElement as HTMLElement;
    const headerInfo = compiled.querySelector('.sbb-header-info');
    expect(headerInfo?.querySelector('strong')?.textContent).toContain('DAS Admintool');
    expect(headerInfo?.querySelector("span")?.textContent).toContain(`V. ${packageJson.version}`);
  });
});
