import { ComponentRef } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ConfirmDeleteService } from '~shared/services/confirm-delete.service';
import { TableBottomBar } from './table-bottom-bar';

const mockConfirmDeleteService = { confirm: vi.fn() };

describe('TableBottomBar', () => {
  let component: TableBottomBar;
  let componentRef: ComponentRef<TableBottomBar>;
  let fixture: ComponentFixture<TableBottomBar>;
  let element: HTMLElement;

  beforeEach(async () => {
    vi.clearAllMocks();
    await TestBed.configureTestingModule({
      imports: [TableBottomBar],
      providers: [{ provide: ConfirmDeleteService, useValue: mockConfirmDeleteService }],
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

  describe('delete', () => {
    let spy: () => void;

    beforeEach(() => {
      componentRef.setInput('deleteDisabled', false);
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

  it('should use custom addLabel', () => {
    componentRef.setInput('addLabel', 'Custom Label');
    fixture.detectChanges();

    const addButton = element.querySelector('sbb-secondary-button');
    expect(addButton?.textContent).toContain('Custom Label');
  });
});
