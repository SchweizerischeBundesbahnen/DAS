import {ComponentFixture, TestBed} from '@angular/core/testing';

import {Holidays} from './holidays';

describe('Holidays', () => {
  let component: Holidays;
  let fixture: ComponentFixture<Holidays>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Holidays]
    })
      .compileComponents();

    fixture = TestBed.createComponent(Holidays);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

