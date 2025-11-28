import {ComponentFixture, TestBed} from '@angular/core/testing';

import {Page} from './page';
import {provideZonelessChangeDetection} from '@angular/core';

describe('Page', () => {
  let component: Page;
  let fixture: ComponentFixture<Page>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Page],
      providers: [provideZonelessChangeDetection()]
    })
      .compileComponents();

    fixture = TestBed.createComponent(Page);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
