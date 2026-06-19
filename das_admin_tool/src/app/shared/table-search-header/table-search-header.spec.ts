import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ComponentRef } from '@angular/core';
import { FormControl } from '@angular/forms';
import { TableSearchHeader } from './table-search-header';

describe('TableSearchHeader', () => {
  let component: TableSearchHeader;
  let componentRef: ComponentRef<TableSearchHeader>;
  let fixture: ComponentFixture<TableSearchHeader>;
  let element: HTMLElement;

  const searchControl = new FormControl('', { nonNullable: true });
  const languageControl = new FormControl('de', { nonNullable: true });

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TableSearchHeader],
    }).compileComponents();

    fixture = TestBed.createComponent(TableSearchHeader);
    component = fixture.componentInstance;
    element = fixture.nativeElement as HTMLElement;
    componentRef = fixture.componentRef;
    componentRef.setInput('searchControl', searchControl);
    componentRef.setInput('languageControl', languageControl);
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should render search field by default', () => {
    const searchInput = element.querySelector('input[type="text"]');
    expect(searchInput).toBeTruthy();
  });

  it('should render language select by default', () => {
    const select = element.querySelector('sbb-select');
    expect(select).toBeTruthy();
  });

  it('should hide language select when languageControl is not set', () => {
    componentRef.setInput('languageControl', undefined);
    fixture.detectChanges();

    const select = element.querySelector('sbb-select');
    expect(select).toBeFalsy();
  });

  it('should bind searchControl to input', () => {
    searchControl.setValue('test');
    fixture.detectChanges();

    const searchInput = element.querySelector<HTMLInputElement>('input[type="text"]')!;
    expect(searchInput.value).toBe('test');
  });
});
