import {ComponentFixture, TestBed} from '@angular/core/testing';

import {RuAdmin} from './ru-admin';

describe('RuAdmin', () => {
  let component: RuAdmin;
  let fixture: ComponentFixture<RuAdmin>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RuAdmin],

    })
      .compileComponents();

    fixture = TestBed.createComponent(RuAdmin);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
