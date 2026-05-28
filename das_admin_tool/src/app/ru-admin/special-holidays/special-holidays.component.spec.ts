import {ComponentFixture, TestBed} from '@angular/core/testing';

import {SpecialHolidays} from './special-holidays.component';
import {SpecialHolidayService} from './special-holiday.service';

const specialHolidayServiceMock = {
  specialHolidaysResource: new Proxy({}, { get: () => vi.fn() })
};

describe('SpecialHolidays', () => {
  let component: SpecialHolidays;
  let fixture: ComponentFixture<SpecialHolidays>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [SpecialHolidays],
      providers: [
        {provide: SpecialHolidayService, useValue: specialHolidayServiceMock},
      ],
    })
      .compileComponents();

    fixture = TestBed.createComponent(SpecialHolidays);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

