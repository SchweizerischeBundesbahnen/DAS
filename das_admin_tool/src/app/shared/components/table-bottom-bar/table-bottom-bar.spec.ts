import { ComponentFixture, TestBed } from '@angular/core/testing';
import { TableBottomBar } from './table-bottom-bar';

describe('TableBottomBar', () => {
  let component: TableBottomBar;
  let fixture: ComponentFixture<TableBottomBar>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TableBottomBar],
    }).compileComponents();

    fixture = TestBed.createComponent(TableBottomBar);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should expose paginator', () => {
    expect(component.paginator()).toBeTruthy();
  });
});
