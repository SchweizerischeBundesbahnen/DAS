import { Component, DestroyRef, inject, OnDestroy, OnInit } from '@angular/core';
import { SbbTableWrapper } from "@sbb-esta/angular/table";
import { Session, SessionsService } from "./sessions.service";
import { DatePipe } from "@angular/common";
import { Router } from "@angular/router";
import { takeUntilDestroyed } from "@angular/core/rxjs-interop";
import { SbbNotification } from "@sbb-esta/angular/notification";


@Component({
  selector: 'app-sfera-discover',
  imports: [
    SbbTableWrapper,
    DatePipe,
    SbbNotification
  ],
  templateUrl: './sfera-discover.component.html',
  styleUrl: './sfera-discover.component.scss'
})
export class SferaDiscoverComponent implements OnInit, OnDestroy {

  protected sessions?: Session[];
  protected refreshedAt?: Date;
  protected isError = false;
  private _destroyed = inject(DestroyRef);
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
      .subscribe({
        next: (sessions) => {
          this.sessions = sessions
            .sort((a, b) => {
              const timeA = a.timestamp ? new Date(a.timestamp).getTime() : Number.NEGATIVE_INFINITY;
              const timeB = b.timestamp ? new Date(b.timestamp).getTime() : Number.NEGATIVE_INFINITY;
              return timeB - timeA;
            });
          this.refreshedAt = new Date();
          this.isError = false;
        },
        error: () => this.isError = true
      });
  }

  openObserver(session: Session) {
    this.router.navigate(['sfera', session]);
  }
}
