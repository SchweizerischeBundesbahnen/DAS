import {ComponentFixture, TestBed} from '@angular/core/testing';

import {NoticeTemplates} from './notice-templates';

describe('NoticeTemplates', () => {
  let component: NoticeTemplates;
  let fixture: ComponentFixture<NoticeTemplates>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [NoticeTemplates]
    })
      .compileComponents();

    fixture = TestBed.createComponent(NoticeTemplates);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
