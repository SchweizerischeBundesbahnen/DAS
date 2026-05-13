import {ComponentFixture, TestBed} from '@angular/core/testing';

import {RuAdmin} from './ru-admin';
import {provideRouter} from '@angular/router';

describe('RuAdmin', () => {
  let component: RuAdmin;
  let fixture: ComponentFixture<RuAdmin>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RuAdmin],
      providers: [provideRouter([])]
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
