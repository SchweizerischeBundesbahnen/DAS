import { ComponentRef } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { PageHeader } from './page-header';

describe('PageHeader', () => {
  let component: PageHeader;
  let componentRef: ComponentRef<PageHeader>;
  let fixture: ComponentFixture<PageHeader>;
  let element: HTMLElement;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PageHeader],
    }).compileComponents();

    fixture = TestBed.createComponent(PageHeader);
    component = fixture.componentInstance;
    element = fixture.nativeElement as HTMLElement;
    componentRef = fixture.componentRef;
    componentRef.setInput('title', 'EVUs');
    await fixture.whenStable();
  });

  it('should render title', () => {
    expect(element.querySelector('sbb-title')?.textContent).toContain('EVUs');
  });

  it('should emit addClicked on add button click', () => {
    const spy = vi.fn();
    component.addClicked.subscribe(spy);

    element.querySelector<HTMLElement>('sbb-button')?.click();

    expect(spy).toHaveBeenCalled();
  });

  it('should hide add button when showAdd is false', () => {
    componentRef.setInput('showAdd', false);
    fixture.detectChanges();

    expect(element.querySelector('sbb-button')).toBeFalsy();
  });

  it('should hide delete button without selection', () => {
    expect(element.querySelector('sbb-transparent-button')).toBeFalsy();
  });

  it('should show delete button with selected count when entries are selected', () => {
    componentRef.setInput('selectedCount', 3);
    fixture.detectChanges();

    expect(element.querySelector('sbb-transparent-button')?.textContent).toContain(
      '3 Einträge löschen',
    );
  });

  it('should emit deleteClicked on delete button click', () => {
    componentRef.setInput('selectedCount', 1);
    fixture.detectChanges();
    const spy = vi.fn();
    component.deleteClicked.subscribe(spy);

    element.querySelector('sbb-transparent-button')?.click();

    expect(spy).toHaveBeenCalled();
  });

  it('should show loading delete button while deleting', () => {
    componentRef.setInput('selectedCount', 1);
    componentRef.setInput('deleting', true);
    fixture.detectChanges();

    expect(element.querySelector('sbb-transparent-button')?.loading).toBe(true);
  });
});
