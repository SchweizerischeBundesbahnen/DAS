import { ComponentRef } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { TableBottomBar } from './table-bottom-bar';

describe('TableBottomBar', () => {
  let component: TableBottomBar;
  let componentRef: ComponentRef<TableBottomBar>;
  let fixture: ComponentFixture<TableBottomBar>;
  let element: HTMLElement;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TableBottomBar],
    }).compileComponents();

    fixture = TestBed.createComponent(TableBottomBar);
    component = fixture.componentInstance;
    element = fixture.nativeElement as HTMLElement;
    componentRef = fixture.componentRef;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should expose paginator', () => {
    expect(component.paginator()).toBeTruthy();
  });

  it('should emit addClicked on add button click', () => {
    const spy = vi.fn();
    component.addClicked.subscribe(spy);

    const addButton = element.querySelector('sbb-secondary-button');
    addButton?.click();

    expect(spy).toHaveBeenCalled();
  });

  it('should show delete button by default', () => {
    const deleteButton = element.querySelector('sbb-transparent-button');
    expect(deleteButton).toBeTruthy();
  });

  it('should hide delete button when showDelete is false', () => {
    componentRef.setInput('showDelete', false);
    fixture.detectChanges();

    const deleteButton = element.querySelector('sbb-transparent-button');
    expect(deleteButton).toBeFalsy();
  });

  it('should emit deleteClicked on delete button click', () => {
    componentRef.setInput('deleteDisabled', false);
    fixture.detectChanges();

    const spy = vi.fn();
    component.deleteClicked.subscribe(spy);

    const deleteButton = element.querySelector('sbb-transparent-button');
    deleteButton?.click();

    expect(spy).toHaveBeenCalled();
  });

  it('should use custom addLabel', () => {
    componentRef.setInput('addLabel', 'Custom Label');
    fixture.detectChanges();

    const addButton = element.querySelector('sbb-secondary-button');
    expect(addButton?.textContent).toContain('Custom Label');
  });
});
