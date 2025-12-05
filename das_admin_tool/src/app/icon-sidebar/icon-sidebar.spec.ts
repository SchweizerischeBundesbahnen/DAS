import {ComponentFixture, TestBed} from '@angular/core/testing';

import {IconSidebar} from './icon-sidebar';
import {provideZonelessChangeDetection} from '@angular/core';

describe('IconSidebar', () => {
  let component: IconSidebar;
  let fixture: ComponentFixture<IconSidebar>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [IconSidebar],
      providers: [provideZonelessChangeDetection()]
    })
      .compileComponents();

    fixture = TestBed.createComponent(IconSidebar);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
