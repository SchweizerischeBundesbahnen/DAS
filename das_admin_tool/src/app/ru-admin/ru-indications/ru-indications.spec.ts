import { ComponentFixture, TestBed } from '@angular/core/testing';
import { RuIndications } from './ru-indications';
import { RuIndicationService } from './ru-indication.service';

const mockRuIndicationService = {
  ruIndicationsResource: new Proxy({}, { get: () => vi.fn() }),
};

describe('RuIndications', () => {
  let component: RuIndications;
  let fixture: ComponentFixture<RuIndications>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RuIndications],
      providers: [{ provide: RuIndicationService, useValue: mockRuIndicationService }],
    }).compileComponents();

    fixture = TestBed.createComponent(RuIndications);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
