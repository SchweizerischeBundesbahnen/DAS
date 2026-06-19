import { ComponentFixture, TestBed } from '@angular/core/testing';
import { createContentFormGroup } from '~ru-admin/ru-indication-content-form/ru-indication-content-form.component';
import { RuIndicationDialogData } from '~ru-admin/ru-indications/ru-indication.service';
import { CategoryContentForm } from './category-content-form';

describe('CategoryContentForm', () => {
  let component: CategoryContentForm;
  let fixture: ComponentFixture<CategoryContentForm>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({ imports: [CategoryContentForm] }).compileComponents();

    fixture = TestBed.createComponent(CategoryContentForm);
    component = fixture.componentInstance;
    const dialogData: RuIndicationDialogData = { templates: [] };
    fixture.componentRef.setInput('form', createContentFormGroup());
    fixture.componentRef.setInput('dialogData', dialogData);
    fixture.detectChanges();
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
