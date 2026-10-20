import { ComponentFixture, TestBed } from '@angular/core/testing';
import { RuFeatureToggleService } from './ru-feature-toggle.service';
import { RuFeatureToggles } from './ru-feature-toggles';

const ruFeatureToggleServiceMock = {
  ruFeaturesResource: new Proxy({}, { get: () => vi.fn() }),
};

describe('RuFeatureToggles', () => {
  let component: RuFeatureToggles;
  let fixture: ComponentFixture<RuFeatureToggles>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RuFeatureToggles],
      providers: [{ provide: RuFeatureToggleService, useValue: ruFeatureToggleServiceMock }],
    }).compileComponents();

    fixture = TestBed.createComponent(RuFeatureToggles);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
