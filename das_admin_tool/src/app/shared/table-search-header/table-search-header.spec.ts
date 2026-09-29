import { ComponentRef, Injector, signal } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FieldTree, form } from '@angular/forms/signals';
import { TableSearchHeader } from './table-search-header';

describe('TableSearchHeader', () => {
  let component: TableSearchHeader;
  let componentRef: ComponentRef<TableSearchHeader>;
  let fixture: ComponentFixture<TableSearchHeader>;
  let element: HTMLElement;

  let searchField: FieldTree<string>;
  let languageField: FieldTree<string>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TableSearchHeader],
    }).compileComponents();

    fixture = TestBed.createComponent(TableSearchHeader);
    component = fixture.componentInstance;
    element = fixture.nativeElement as HTMLElement;
    componentRef = fixture.componentRef;
    searchField = form(signal(''), { injector: TestBed.inject(Injector) });
    languageField = form(signal('de'), { injector: TestBed.inject(Injector) });
    componentRef.setInput('searchField', searchField);
    componentRef.setInput('languageField', languageField);
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

  it('should hide language select when languageField is not set', () => {
    componentRef.setInput('languageField', undefined);
    fixture.detectChanges();

    const select = element.querySelector('sbb-select');
    expect(select).toBeFalsy();
  });

  it('should bind searchField to input', () => {
    searchField().value.set('test');
    fixture.detectChanges();

    const searchInput = element.querySelector<HTMLInputElement>('input[type="text"]')!;
    expect(searchInput.value).toBe('test');
  });
});
