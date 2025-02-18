import { Component, DestroyRef, inject, OnDestroy, OnInit } from '@angular/core';
import { SbbTableWrapper } from "@sbb-esta/angular/table";
import { Session, SessionsService } from "./sessions.service";
import { DatePipe } from "@angular/common";
import { Router } from "@angular/router";
import { takeUntilDestroyed } from "@angular/core/rxjs-interop";


@Component({
  selector: 'app-sfera-discover',
  standalone: true,
  imports: [
    SbbTableWrapper,
    DatePipe
  ],
  templateUrl: './sfera-discover.component.html',
  styleUrl: './sfera-discover.component.scss'
})
export class SferaDiscoverComponent implements OnInit, OnDestroy {

  private _destroyed = inject(DestroyRef);
  protected sessions?: Session[];
  private interval?: NodeJS.Timeout;

  constructor(private sessionsService: SessionsService, private router: Router) {
  }

  ngOnDestroy(): void {
    clearInterval(this.interval)
  }

  async ngOnInit() {
    this.fetchSessions();
    this.interval = setInterval(() => {
      this.fetchSessions()
    }, 3000);
  }

  fetchSessions() {
    this.sessionsService.getSessions()
      .pipe(takeUntilDestroyed(this._destroyed))
      .subscribe(sessions => this.sessions = sessions);
  }

  openObserver(session: Session) {
    this.router.navigate(['sfera', session]);
  }
}
