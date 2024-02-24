#include <stddef.h>
#include "ll_cycle.h"

int ll_has_cycle(node *head) {
    if(head == NULL) return 0;
    node* fast = head;
    node* slow = head;
    int cnt = 0;
    while(fast->next != NULL && slow->next != NULL){
        fast = fast->next;
        if(fast->next == NULL) return 0;
        fast = fast->next;
        slow = slow->next;
        if(fast == slow) return 1;
    }
    return 0;
}
