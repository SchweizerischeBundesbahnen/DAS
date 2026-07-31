import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { DasAdmin } from './das-admin';

describe('DasAdmin', () => {
  let component: DasAdmin;
  let fixture: ComponentFixture<DasAdmin>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DasAdmin],
      providers: [provideRouter([])],
    }).compileComponents();

    fixture = TestBed.createComponent(DasAdmin);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
