import {ComponentFixture, TestBed} from '@angular/core/testing';

import {DasAdmin} from './das-admin';

describe('DasAdmin', () => {
  let component: DasAdmin;
  let fixture: ComponentFixture<DasAdmin>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DasAdmin],

    })
      .compileComponents();

    fixture = TestBed.createComponent(DasAdmin);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
