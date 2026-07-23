import { ComponentFixture, TestBed } from '@angular/core/testing';
import { RuFeatureToggles } from './ru-feature-toggles.component';
import { RuFeatureService } from './ru-feature.service';

const ruFeatureServiceMock = {
  ruFeaturesResource: new Proxy({}, { get: () => vi.fn() }),
};

describe('RuFeatureToggles', () => {
  let component: RuFeatureToggles;
  let fixture: ComponentFixture<RuFeatureToggles>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RuFeatureToggles],
      providers: [{ provide: RuFeatureService, useValue: ruFeatureServiceMock }],
    }).compileComponents();

    fixture = TestBed.createComponent(RuFeatureToggles);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
