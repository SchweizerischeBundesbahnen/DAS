import {ComponentFixture, TestBed} from '@angular/core/testing';

import {IconSidebar} from './icon-sidebar';

describe('IconSidebar', () => {
  let component: IconSidebar;
  let fixture: ComponentFixture<IconSidebar>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [IconSidebar],
    })
      .compileComponents();

    fixture = TestBed.createComponent(IconSidebar);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
