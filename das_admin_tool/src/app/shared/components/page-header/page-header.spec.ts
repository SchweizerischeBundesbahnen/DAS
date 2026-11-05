import { ComponentRef } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ConfirmDeleteService } from '~shared/services/confirm-delete.service';
import { PageHeader } from './page-header';

const mockConfirmDeleteService = { confirm: vi.fn() };

describe('PageHeader', () => {
  let component: PageHeader;
  let componentRef: ComponentRef<PageHeader>;
  let fixture: ComponentFixture<PageHeader>;
  let element: HTMLElement;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PageHeader],
      providers: [{ provide: ConfirmDeleteService, useValue: mockConfirmDeleteService }],
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

  describe('delete', () => {
    let spy: () => void;

    beforeEach(() => {
      componentRef.setInput('selectedCount', 3);
      fixture.detectChanges();
      spy = vi.fn();
      component.deleteClicked.subscribe(spy);
    });

    async function clickDelete() {
      element.querySelector('sbb-transparent-button')?.click();
      await Promise.resolve();
    }

    it('should ask for confirmation with the number of selected entries', async () => {
      mockConfirmDeleteService.confirm.mockResolvedValue(false);

      await clickDelete();

      expect(mockConfirmDeleteService.confirm).toHaveBeenCalledWith(3);
    });

    it('should emit deleteClicked once when confirmed', async () => {
      mockConfirmDeleteService.confirm.mockResolvedValue(true);

      await clickDelete();

      expect(spy).toHaveBeenCalledTimes(1);
    });

    it('should not emit deleteClicked when cancelled', async () => {
      mockConfirmDeleteService.confirm.mockResolvedValue(false);

      await clickDelete();

      expect(spy).not.toHaveBeenCalled();
    });
  });

  it('should show loading delete button while deleting', () => {
    componentRef.setInput('selectedCount', 1);
    componentRef.setInput('deleting', true);
    fixture.detectChanges();

    expect(element.querySelector('sbb-transparent-button')?.loading).toBe(true);
  });
});
