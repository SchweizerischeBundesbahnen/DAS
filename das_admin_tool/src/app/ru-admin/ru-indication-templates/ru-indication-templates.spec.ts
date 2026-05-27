import {ComponentFixture, TestBed} from '@angular/core/testing';

import {RuIndicationTemplates} from './ru-indication-templates';

describe('RuIndicationTemplates', () => {
  let component: RuIndicationTemplates;
  let fixture: ComponentFixture<RuIndicationTemplates>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RuIndicationTemplates]
    })
      .compileComponents();

    fixture = TestBed.createComponent(RuIndicationTemplates);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
